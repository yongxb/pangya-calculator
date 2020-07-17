import "package:flutter/material.dart";
import 'dart:math';
import 'package:pangya_calculator/Screens/labeledRadio.dart';


class Calculator6iForm extends StatefulWidget {
  @override
  _Calculator6iFormState createState() => _Calculator6iFormState();
}

//bool _isRadioSelected = false;

class _Calculator6iFormState extends State<Calculator6iForm> {
  // Initialize Text Fields
  TextEditingController _maxPowerController = TextEditingController();
  String maxPower = "141";
  TextEditingController _pinDistanceController = TextEditingController();
  String pinDistance = "20";
  TextEditingController _elevationController = TextEditingController();
  String elevation = "0";
  TextEditingController _windSpeedController = TextEditingController();
  String windSpeed = "5";
  TextEditingController _windAngleController = TextEditingController();
  String windAngle = "45";
  TextEditingController _breaksController = TextEditingController();
  String breaks = "0";
  TextEditingController _terrainController = TextEditingController();
  String terrain = "100";

  double caliperPower = 141;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;
  double _maxPower = 141;
  double _pinDistance = 25;
  double _elevation = 0;
  double _windSpeed = 1;
  double _windAngle = 45;
  double _breaks = 0;

  bool _isRadioSelected = true;
  double maxDist;

  var terrainDunk = {"100":1, "98":1/0.98, "97":1/0.97, "95":1/0.95, "92":1/0.92, "90":1/0.9, "87":1/0.87, "85":1/0.85, "82":1/0.82, "80":1/0.8, "75":1/0.75};
//  var terrainDunk = {"100":1, "98":1.02, "97":1.03, "95":1.05, "92":1.08, "90":1.1, "87":1.13, "85":1.16, "82":1.18, "80":1.2, "75":1.25};

  @override
  void initState() {
    _maxPowerController.text = maxPower;
    _pinDistanceController.text = pinDistance;
    _elevationController.text = elevation;
    _windSpeedController.text = windSpeed;
    _windAngleController.text = windAngle;
    _breaksController.text = breaks;
    _terrainController.text = terrain;

    maxDistCalc(141.0);
    return super.initState();
  }

  double powerFn(double x){
    return x*0.32849496*log(1.05924966*x+1e-6) + x*0.71896443*exp(-0.07405188*x);
  }

  void maxDistCalc(double maxPower) {
    setState(() {
      double _maxDistTemp = maxPower - 18;
      double _powerCalcMax = powerFn(_maxDistTemp);

      while ((maxPower - _powerCalcMax).abs() > 0.01){
        _maxDistTemp = _maxDistTemp + (maxPower - _powerCalcMax);
        _powerCalcMax = powerFn(_maxDistTemp);
      }

      maxDist = _maxDistTemp;
    });
  }

  void calculateDunk6i() {
    setState(() {
      double hwiCoefficient = 0.477;

      double trueDist = _pinDistance * terrainDunk[terrain];

      double deltaH;
      double inf;
      double variation;
      double elevationInfH;

      if(_elevation >= 0.0){
        deltaH = 0.04656938 * exp(0.02410579 * _elevation) + 0.65046932;
        inf = 3.8;
        variation = 1.002;
      } else {
        deltaH = -0.01628496 * exp(-0.04846523 * _elevation) + 0.70932074;
        inf = 3.2;
        variation = 1.0015;
      }

      deltaH = deltaH * pow(variation, (maxDist - trueDist));

      double realAltitude = _elevation * deltaH;
      double infH = 1 - (realAltitude / inf)/100;

      print(realAltitude);
      double hwi = hwiCoefficient * (exp(0.01 * trueDist) - 1);
      double windMovement = hwi * _windSpeed * cos(_windAngle*pi/180) * infH;

      if(_isRadioSelected == true){
        elevationInfH = hwi * _windSpeed * sin(_windAngle*pi/180) * (1-realAltitude*0.016);
        windMovement = windMovement * (1 - elevationInfH*2.75/400);
      } else {
        elevationInfH = hwi * _windSpeed * sin(_windAngle*pi/180) * 1.3 * (1-realAltitude*0.013);
        windMovement = windMovement / (1 - elevationInfH*4/625);
      }

      finalMovement = (windMovement + _breaks*hwi/4) / 0.218;
      finalMovement = num.parse(finalMovement.toStringAsFixed(2));
      finalMovementCaliperLeft = (0.5 - (finalMovement % 5) / 10) * _maxPower;
      finalMovementCaliperLeft = num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
      finalMovementCaliperRight = (0.5 + (finalMovement % 5) / 10) * _maxPower;
      finalMovementCaliperRight = num.parse(finalMovementCaliperRight.toStringAsFixed(2));

      finalMovement4 = finalMovement / 4;
      finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

      finalMovement4CaliperLeft = (0.5 - (finalMovement4 % 5) / 10) * _maxPower;
      finalMovement4CaliperLeft = num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
      finalMovement4CaliperRight = (0.5 + (finalMovement4 % 5) / 10) * _maxPower;
      finalMovement4CaliperRight = num.parse(finalMovement4CaliperRight.toStringAsFixed(2));

      double force;
      if(_isRadioSelected == true) {
        force = trueDist + realAltitude - elevationInfH;
      } else {
        force = trueDist + realAltitude + elevationInfH;
      }

      caliperPower = powerFn(force);
      caliperPower = num.parse(caliperPower.toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                      ),
                      child: Text('Caliper power (Max Power: $maxPower | Terrain: $terrain)', textAlign: TextAlign.left,),
                    ),
                  ),
                  new Text(
                    '$caliperPower',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Text('PB ($finalMovementCaliperRight | $finalMovementCaliperLeft)',textAlign: TextAlign.left,),
                              ),
                            ),
                            new Text(
                              '$finalMovement',
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
                                child: Text('PB / 4 ($finalMovement4CaliperRight | $finalMovement4CaliperLeft)',textAlign: TextAlign.left,),
                              ),
                            ),
                            new Text(
                              '$finalMovement4',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 2,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Pin Distance',
                                hintText: '230'
                            ),
                            keyboardType: TextInputType.number,
                            controller: _pinDistanceController,
                            onChanged: (String value) {
                              pinDistance = value;
                              _pinDistance = double.parse(pinDistance);
                              calculateDunk6i();
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Elevation',
                                hintText: '0'
                            ),
                            keyboardType: TextInputType.number,
                            controller: _elevationController,
                            onChanged: (String value) {
                              elevation = value;
                              _elevation = double.parse(elevation);
                              calculateDunk6i();
                            },
                          ),
                        ),
                      ]
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Wind Speed',
                                hintText: '1'
                            ),
                            keyboardType: TextInputType.number,
                            controller: _windSpeedController,
                            onChanged: (String value) {
                              windSpeed = value;
                              _windSpeed = double.parse(windSpeed);
                              calculateDunk6i();
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Wind Angle',
                                hintText: '0'
                            ),
                            keyboardType: TextInputType.number,
                            controller: _windAngleController,
                            onChanged: (String value) {
                              windAngle = value;
                              _windAngle = double.parse(windAngle);
                              calculateDunk6i();
                            },
                          ),
                        ),
                      ]
                  ),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                          ),
                          child: Text("Wind Direction:",textAlign: TextAlign.left,),
                        ),
                      ),
                      LabeledRadio(
                        label: 'Forward',
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        value: true,
                        groupValue: _isRadioSelected,
                        onChanged: (bool newValue) {
                          setState(() {
                            _isRadioSelected = newValue;
                          });
                          calculateDunk6i();
                        },
                      ),
                      LabeledRadio(
                        label: 'Backward',
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        value: false,
                        groupValue: _isRadioSelected,
                        onChanged: (bool newValue) {
                          setState(() {
                            _isRadioSelected = newValue;
                          });
                          calculateDunk6i();
                        },
                      ),
                    ],
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Breaks',
                                hintText: '0'
                            ),
                            keyboardType: TextInputType.number,
                            controller: _breaksController,
                            onChanged: (String value) {
                              breaks = value;
                              _breaks = double.parse(breaks);
                              calculateDunk6i();
                            },
                          ),
                        ),
                      ]
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Terrain',
                        hintText: '0'
                    ),
                    keyboardType: TextInputType.number,
                    controller: _terrainController,
                    onChanged: (String value) {
                      terrain = value;
                      calculateDunk6i();
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Max Power',
                        hintText: '280'
                    ),
                    keyboardType: TextInputType.number,
                    controller: _maxPowerController,
                    onChanged: (String value) {
                      maxPower = value;
                      _maxPower = double.parse(maxPower);
                      maxDistCalc(_maxPower);
                      calculateDunk6i();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}