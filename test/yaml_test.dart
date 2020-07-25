import "dart:io";
import "package:yaml/yaml.dart";


class ParseYAML {
  Map loadYamlFileSync(String path) {
    File file = new File(path);
    if (file?.existsSync() == true) {
      return loadYaml(file.readAsStringSync());
    }
    return null;
  }

  List<String> parseYAMLtoList(var doc){
    List<String> pinDescription = [];

    doc["course"].forEach((key, course) {
      String _courseShortForm = course["short"];
      course["holes"].forEach((k, holes) {
        String _hole = holes["name"];
        holes["pins"].forEach((k2, v2) {
          pinDescription.add('$_courseShortForm $_hole $k2');
        });
      });
    });
    print(pinDescription);
    return pinDescription;
  }

  List<double> obtainPinInformation(String pin, var doc){
    List<double> results = [];
    List<String> pinSplit = pin.split(' ');

    results.add(doc["course"][pinSplit[0]]["holes"][pinSplit[1]]["pins"][pinSplit[2]]["pinDistance"]);
    results.add(doc["course"][pinSplit[0]]["holes"][pinSplit[1]]["pins"][pinSplit[2]]["pinHeight"]);

    return results;
  }
}

final doc = ParseYAML().loadYamlFileSync("assets/pinLocation.yaml");
final pinDescription = ParseYAML().parseYAMLtoList(doc);


void main() {
  List<double> results;

  results = ParseYAML().obtainPinInformation(pinDescription[20], doc);

  print(pinDescription[20]);
  print(results[0]);
  print(results[1]);
}
