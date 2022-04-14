import 'package:flutter/material.dart';
import 'package:pangya_calculator/blocs/calculatorBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pangya_calculator/appConfig.dart';
import 'package:flutter/services.dart' show rootBundle;
import "package:yaml/yaml.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalculatorWidget extends StatefulWidget{
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {

  TextEditingController  _pinDistanceController = TextEditingController();
  TextEditingController  _elevationController = TextEditingController();

  Future<List<String>> loadPinLocation(String courseName) async {
    final data = await rootBundle.loadString('assets/pinLocation.yaml');
    final mapData = loadYaml(data);

    List<String> pinDescription = [];
    mapData["course"][courseName]["holes"].forEach((k, holes) {
      String _hole = holes["name"];
      holes["pins"].forEach((k2, v2) {
        pinDescription.add('$_hole $k2');
      });
    });
    return pinDescription;
  }

  Future<List<String>> loadCourses() async {
    final data = await rootBundle.loadString('assets/pinLocation.yaml');
    final mapData = loadYaml(data);

    List<String> courseDescription = [];

    mapData["course"].forEach((key, course) {
      courseDescription.add(course["name"]);
    });
    return courseDescription;
  }

  @override
  void dispose(){
    super.dispose();
    _pinDistanceController.dispose();
    _elevationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        margin: EdgeInsets.all(7.0),
        child: Column(
          children: <Widget>[
            BlocBuilder<CalculatorBloc, CalculatorState>(
                builder: (context, state) {
                if (state is CalculatorSuccess) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                            ),
                            child: StreamBuilder(
                                stream: context.bloc<CalculatorBloc>().maxPower,
                                builder: (context, snapshot) {
                                  String maxPower;
                                  if (snapshot.data == null){
                                    maxPower = appData.maxPower1WDunk.toString();
                                  } else {
                                    maxPower = snapshot.data;
                                  }
                                  return Text(
                                    'Caliper power (Max Power: $maxPower | Terrain: ${appData
                                        .terrain} | Spin: ${appData.spin})',
                                    textAlign: TextAlign.left,);
                                }
                            ),
                          )
                        ),
                        Text('${state.result.caliperPower}',
                          style: Theme.of(context).textTheme.headline4,),
                        Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text('PB (${state.result.finalMovementCaliperRight} | ${state.result.finalMovementCaliperLeft})',
                                        textAlign: TextAlign.left,),
                                    ),
                                  ),
                                  new Text(
                                    '${state.result.finalMovement}',
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text('PB / 4 (${state.result.finalMovement4CaliperRight} | ${state.result.finalMovement4CaliperLeft})',
                                        textAlign: TextAlign.left,),
                                    ),
                                  ),
                                  new Text(
                                    '${state.result.finalMovement4}',
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]
                  );
                } else {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                            ),
                            child: Text('Caliper power (Max Power: | Terrain: | Spin: )',
                              textAlign: TextAlign.left,),
                          ),
                        ),
                        Text('', style: Theme.of(context).textTheme.headline4,),
                        Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text('PB ( | )',
                                        textAlign: TextAlign.left,),
                                    ),
                                  ),
                                  new Text('',style: Theme.of(context).textTheme.headline4,),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                      child: Text('PB / 4 ( | )',
                                        textAlign: TextAlign.left,),
                                    ),
                                  ),
                                  new Text('', style: Theme.of(context).textTheme.headline4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]
                  );
                }
              }
            ),
            Divider(
              color: Colors.black,
              thickness: 1,
            ),
            Row(
                children: <Widget>[
                  Expanded(
                    child: courseDescriptionField(context),
                  ),
                ]
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded (
                    flex: 2,
                    child: calculationField(context),
                  ),
                  Expanded (
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Column(
                        children: <Widget>[
                          Text("2ps", textAlign: TextAlign.left, style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 21, width: 13, child:
                            Checkbox(
                              value: appData.useDoublePS,
                              onChanged: (bool value) {
                                context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateDoublePS, null));
                                setState(() {});
                              },
                            ),
                          ),
                        ]
                      )
                    )
                  ),
                  Expanded (
                    flex: 3,
                    child: spinField(context),
                  ),
                ]
            ),
            Row(
                children: <Widget>[
                  Expanded(
                    child: pinDistanceField(context),
                  ),
                  Expanded(
                    child: elevationField(context),
                  ),
                ]
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: windSpeedField(context),
                  ),
                  Expanded(
                    child: windAngleField(context),
                  ),
                ]
            ),
            Padding(
              padding: EdgeInsets.only(top:8),
              child: Container(
                height: 35,
                child: windDirectionField(context),
              )
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: terrainField(context),
                  ),
                  Expanded(
                    child: breaksField(context),
                  ),
                ]
            ),
          ],
        ),
    );
  }

  Widget calculationField(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<CalculatorBloc>().calculationSelected,
      builder: (context, snapshot) {
        String calculatorValue;
        if (snapshot.data == null){
          calculatorValue = '1W Dunk';
        } else {
          calculatorValue = snapshot.data;
        }
        return Row(
            children: <Widget>[
              FaIcon(FontAwesomeIcons.meteor, size: 15, color: Colors.grey,),
              Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: DropdownButton<String>(
                    onChanged: (String value) {
                      context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateCalculator, value));
                      setState(() {});
                    },
                    value: calculatorValue,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    items: <String>['1W Dunk', '1W Toma', '2W Toma', '3W Toma', '6i Beam']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
              )
            ]
        );
      },
    );
  }

  Widget courseDescriptionField(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: loadCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> courseDescription = snapshot.data;
            return StreamBuilder(
              stream: context
                  .bloc<CalculatorBloc>()
                  .courseDescription,
              builder: (context, snapshot2) {
                String courseDescriptionValue;
                if (snapshot2.data == null) {
                  courseDescriptionValue = "Blue Lagoon";
                } else {
                  courseDescriptionValue = snapshot2.data;
                }
                return Row(
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.searchLocation, size: 15, color: Colors.grey,),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: DropdownButton<String>(
                          onChanged: (String value) {
                            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateCourseDescription, value));
                            setState(() {});
                          },
                          value: courseDescriptionValue,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          items: courseDescription.map<DropdownMenuItem<String>>((
                              String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ),
                    ),
                    Expanded(
                        child: pinInformationField(context, courseDescriptionValue),
                    ),
                  ],
                );
              },
            );
          } else {
            return Container(width: 0, height: 0,);
          }
        }
    );
  }

  Widget pinInformationField(BuildContext context, String courseDescription) {
    return FutureBuilder<List<String>>(
        future: loadPinLocation(courseDescription),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> pinDescription = snapshot.data;
            return StreamBuilder(
              stream: context
                  .bloc<CalculatorBloc>()
                  .pinInformation,
              builder: (context, snapshot2) {
                String pinInformationValue;
                if (snapshot2.data == null) {
                  return Container(width: 0, height: 0,);
//                  pinInformationValue = "H2 224.42y";
                } else {
                  pinInformationValue = snapshot2.data;
                }
                return Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: DropdownButton<String>(
                    onChanged: (String value) {
                      context.bloc<CalculatorBloc>().add(
                          CalculatorEvent(EventType.updatePinDescription, value));
                    },
                    value: pinInformationValue,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    items: pinDescription.map<DropdownMenuItem<String>>((
                        String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                );
              },
            );
          } else {
            return Container(width: 0, height: 0,);
          }
        }
    );
  }

  Widget pinDistanceField(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<CalculatorBloc>().pinDistance,
      builder: (context, snapshot) {
        _pinDistanceController.value = _pinDistanceController.value.copyWith(text: snapshot.data);
        return Padding(
            padding: EdgeInsets.only(right: 10),
            child: TextFormField(
              controller: _pinDistanceController,
              onChanged: (String value) {
                context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updatePinDistance, value));
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pin Distance',
                icon: FaIcon(FontAwesomeIcons.golfBall, size: 15),
              ),
            )
        );
      },
    );
  }

  Widget elevationField(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<CalculatorBloc>().elevation,
      builder: (context, snapshot) {
        _elevationController.value = _elevationController.value.copyWith(text: snapshot.data);
        return Padding(
            padding: EdgeInsets.only(right: 7),
            child: TextFormField(
              controller: _elevationController,
              onChanged: (String value) {
                context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateElevation, value));
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Elevation',
                icon: FaIcon(FontAwesomeIcons.mountain, size: 13,),
              ),
            )
        );
      },
    );
  }

  Widget windSpeedField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return Padding(
            padding: EdgeInsets.only(right: 10, bottom: 3),
        child: TextFormField(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateWindSpeed, value));
          },
          initialValue: '1',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Wind Speed',
            icon: FaIcon(FontAwesomeIcons.wind, size: 15,),
          ),
        )
        );
      },
    );
  }

  Widget windAngleField(BuildContext context) {
    //TODO to add sine/cosine indication to labelText
    return StreamBuilder(
      builder: (context, snapshot) {
        return Padding(
            padding: EdgeInsets.only(right: 7, bottom: 3),
            child: TextFormField(
            onChanged: (String value) {
              context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateWindAngle, value));
            },
            initialValue: '45',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Wind Angle',
              icon: FaIcon(FontAwesomeIcons.locationArrow, size: 15,),
            ),
          )
        );
      },
    );
  }

  Widget windDirectionField(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<CalculatorBloc>().isSelected,
      builder: (context, snapshot) {
        List<bool> isSelected;
        if (snapshot.data == null){
          isSelected = [true, false];
        } else {
          isSelected = snapshot.data;
        }
        return Row(
          children: [
            Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                    ),
                    child: Text("Wind Direction (${appData.angleFunction}):",textAlign: TextAlign.left,),
                  ),
                ),
            ),
            ToggleButtons(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                  ),
                  child: Text("Forward"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                  ),
                  child: Text("Backward"),
                ),
              ],
              onPressed: (int index) {
                context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateWindDirection, index.toString()));
              },
              isSelected: isSelected,
              color: Colors.blueAccent,
              selectedColor: Colors.white,
              fillColor: Colors.blueAccent,
//              splashColor: Colors.blueAccent,
              borderRadius: BorderRadius.circular(5),
              borderWidth: 1,
              borderColor: Colors.grey,
            )
          ],
        );
      },
    );
  }

  Widget breaksField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(right: 5),
          child: TextFormField(
            onChanged: (String value) {
              context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateBreaks, value));
            },
            initialValue: '0',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Breaks',
              icon: FaIcon(FontAwesomeIcons.slash, size: 15,),
            ),
          )
        );
      },
    );
  }

  Widget greenSlopeField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(right: 5),
          child: TextFormField(
            onChanged: (String value) {
              context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateGreenSlope, value));
            },
            initialValue: '0',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Green Slope',
              icon: Icon(Icons.golf_course, size: 20,),
            ),
          )
        );
      },
    );
  }

  Widget terrainField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(right: 5),
          child: TextFormField(
            onChanged: (String value) {
              context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateTerrain, value));
            },
            initialValue: '100',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Terrain',
              icon: FaIcon(FontAwesomeIcons.water, size: 15,),
            ),
          )
        );
      },
    );
  }
}

Widget spinField(BuildContext context) {
  return StreamBuilder(
    builder: (context, snapshot) {
      return Padding(
          padding: EdgeInsets.only(right: 7),
          child: TextFormField(
            onChanged: (String value) {
              context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateSpin, value));
            },
            initialValue: '11',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Spin',
              icon: FaIcon(FontAwesomeIcons.sync, size: 15,),
            ),
          )
      );
    },
  );
}