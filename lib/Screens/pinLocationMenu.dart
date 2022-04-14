import "package:flutter/material.dart";
import "dart:io";
import 'package:yaml/yaml.dart';

class PinLocationMenu extends StatefulWidget {
  _PinLocationMenuState createState() => _PinLocationMenuState();
}

class _PinLocationMenuState extends State<PinLocationMenu>{
  Map loadYamlFileSync(String path) {
    File file = File(path);
    if (file?.existsSync() == true) {
      return loadYaml(file.readAsStringSync());
    }
    return null;
  }

  Map pinLocation;

  void parseYaml(){
    for(var course in pinLocation.keys){
      for (var holes in course.keys){
        continue;
      }
    }
  }
  
  @override
  void initState() {
    pinLocation = loadYamlFileSync("pinLocation.yaml");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }
}