import "package:yaml/yaml.dart";
import 'package:flutter/services.dart' show rootBundle;

class ParseYAML {
  Future<Map> loadYamlAsync() async {
    final data = await rootBundle.loadString('assets/pinLocation.yaml');
    final mapData = await loadYaml(data);

    return mapData;
  }

  Future<List<double>> obtainPinInformation(String course, String pin) async {
    List<double> results = [];
    Map doc = await loadYamlAsync();

    List<String> pinSplit = pin.split(' ');
    results.add(
        doc["course"][course]["holes"][pinSplit[0]]["pins"][pinSplit[1]]["pinDistance"]);
    results.add(
        doc["course"][course]["holes"][pinSplit[0]]["pins"][pinSplit[1]]["pinHeight"]);

    return results;
  }

  Future<String> obtainHoleInformation(String courseName) async {
    Map doc = await loadYamlAsync();

    String key = doc["course"][courseName]["holes"].keys.toList()[0];
    String key2 = doc["course"][courseName]["holes"][key]["pins"].keys.toList()[0];

    String _hole = doc["course"][courseName]["holes"][key]["name"];

    String output ='$_hole $key2';
    return output;
  }
}

