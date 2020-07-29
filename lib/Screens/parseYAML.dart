import "package:yaml/yaml.dart";
import 'package:flutter/services.dart' show rootBundle;

class ParseYAML {
  Future<Map> loadYamlAsync() async {
    final data = await rootBundle.loadString('assets/pinLocation.yaml');
    final mapData = await loadYaml(data);

    return mapData;
  }

  Future<List<double>> obtainPinInformation(String pin) async {
    List<double> results = [];
    Map doc = await loadYamlAsync();

    List<String> pinSplit = pin.split(' ');
    results.add(
        doc["course"][pinSplit[0]]["holes"][pinSplit[1]]["pins"][pinSplit[2]]["pinDistance"]);
    results.add(
        doc["course"][pinSplit[0]]["holes"][pinSplit[1]]["pins"][pinSplit[2]]["pinHeight"]);

    return results;
  }
}

