import 'package:flutter/material.dart';
import 'package:pangya_calculator/blocs/calculatorBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pangya_calculator/appConfig.dart';

class CalculatorWidget extends StatelessWidget {

  TextEditingController  _pinDistanceController = TextEditingController();
  TextEditingController  _elevationController = TextEditingController();

  void dispose(){
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
                                    'Caliper power (Max Power: ${maxPower} | Terrain: ${appData
                                        .terrain} | Spin: ${appData.spin})',
                                    textAlign: TextAlign.left,);
                                }
                            ),
                          )
                        ),
                        Text('${state.result.caliperPower}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline4,),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: calculationField(context),
                  ),
                  Expanded(
                    child: Text("Holes"),
                  ),
                ]
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: breaksField(context),
                  ),
                  Expanded(
                    child: greenSlopeField(context),
                  ),
                ]
            ),
            terrainField(context),
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
        return DropdownButton<String>(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateCalculator, value));
          },
          value: calculatorValue,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          items: <String>['1W Dunk', '1W Tomahawk', '6i Beam']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      },
    );
  }

  Widget pinDistanceField(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<CalculatorBloc>().pinDistance,
      builder: (context, snapshot) {
        _pinDistanceController.value = _pinDistanceController.value.copyWith(text: snapshot.data);
        return TextFormField(
          controller: _pinDistanceController,
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updatePinDistance, value));
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Pin Distance',
          ),
        );
      },
    );
  }

  Widget elevationField(BuildContext context) {
    return StreamBuilder(
      stream: context.bloc<CalculatorBloc>().elevation,
      builder: (context, snapshot) {
        _elevationController.value = _elevationController.value.copyWith(text: snapshot.data);
        return TextFormField(
          controller: _elevationController,
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateElevation, value));
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Elevation',
          ),
        );
      },
    );
  }

  Widget windSpeedField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return TextFormField(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateWindSpeed, value));
          },
          initialValue: '1',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Wind Speed',
          ),
        );
      },
    );
  }

  Widget windAngleField(BuildContext context) {
    //TODO to add sine/cosine indication to labelText
    return StreamBuilder(
      builder: (context, snapshot) {
        return TextFormField(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateWindAngle, value));
          },
          initialValue: '45',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Wind Angle',
          ),
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
        };
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
        return TextFormField(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateBreaks, value));
          },
          initialValue: '0',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Breaks',
          ),
        );
      },
    );
  }

  Widget greenSlopeField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return TextFormField(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateGreenSlope, value));
          },
          initialValue: '0',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Green Slope',
          ),
        );
      },
    );
  }

  Widget terrainField(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        return TextFormField(
          onChanged: (String value) {
            context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updateTerrain, value));
          },
          initialValue: '100',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Terrain',
          ),
        );
      },
    );
  }
}
