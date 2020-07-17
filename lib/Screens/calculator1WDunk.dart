import "package:flutter/material.dart";
import 'dart:math';
import 'package:pangya_calculator/Screens/labeledRadio.dart';

class Calculator1WDunkForm extends StatefulWidget {
  @override
  _Calculator1WDunkFormState createState() => _Calculator1WDunkFormState();
}

class _Calculator1WDunkFormState extends State<Calculator1WDunkForm> {
  // Initialize Text Fields
  TextEditingController  _maxPowerController = TextEditingController();
  String maxPower = "281";
  TextEditingController  _pinDistanceController = TextEditingController();
  String pinDistance = "220";
  TextEditingController  _elevationController = TextEditingController();
  String elevation = "0";
  TextEditingController  _windSpeedController = TextEditingController();
  String windSpeed = "1";
  TextEditingController  _windAngleController = TextEditingController();
  String windAngle = "45";
  TextEditingController  _breaksController = TextEditingController();
  String breaks = "0";
  TextEditingController  _greenSlopeController = TextEditingController();
  String greenSlope = "0";
  TextEditingController  _terrainController = TextEditingController();
  String terrain = "100";

  double caliperPower = 230;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;
  double _maxPower = 281;
  double _pinDistance = 220;
  double _elevation = 0;
  double _windSpeed = 1;
  double _windAngle = 45;
  double _breaks = 0;
  double _greenSlope = 0;

  bool _isRadioSelected = true;

//  var terrainDunk = {"100":0, "98":1.31, "97":1.83, "95":3.31, "92":5.13, "90":6.53, "85":10.14, "82":12.4, "80":13.92, "75":18.05, "70":21.53};
  var terrainDunk = {"100":0, "98":1.3, "97":1.8, "95":3.3, "92":5.1, "90":6.5, "85":10.1, "82":12.4, "80":13.9, "75":18.0, "70":21.5};
  double maxDist;

  @override
  void initState() {
    _maxPowerController.text = maxPower;
    _pinDistanceController.text = pinDistance;
    _elevationController.text = elevation;
    _windSpeedController.text = windSpeed;
    _windAngleController.text = windAngle;
    _breaksController.text = breaks;
    _greenSlopeController.text = greenSlope;
    _terrainController.text = terrain;

    // initialize max Dist
    maxDistCalc(281.0);
    return super.initState();
  }

  void maxDistCalc(double maxPower) {
    setState(() {
      double _maxDistTemp = maxPower - 30;
      Function powerFn = powerCalc(maxPower);
      double _powerCalcMax = powerFn(_maxDistTemp);

      while ((maxPower - _powerCalcMax).abs() > 0.01){
        _maxDistTemp = _maxDistTemp + (maxPower - _powerCalcMax);
        _powerCalcMax = powerFn(_maxDistTemp);
      }

      maxDist = _maxDistTemp;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _maxPowerController.dispose();
    _pinDistanceController.dispose();
    _elevationController.dispose();
    _windSpeedController.dispose();
    _windAngleController.dispose();
    _breaksController.dispose();
    _greenSlopeController.dispose();
    _terrainController.dispose();
    super.dispose();
  }

  double dunk1WHWICoefficient(double x){
    return sqrt(2) * exp(-0.01160687 * x) + 0.03675829;
  }

  double powerCoefficient1(double x) {
    return -1.15061980e+02 * exp(-8.67180403e-03* x) + 2.99284041e+01;
  }

  double powerCoefficient2(double x) {
    return 0.02300804 * exp(-0.01446185 * x) + 0.00054072;
  }

  double powerCoefficient3(double x) {
    return -1.72036246e+02 * exp(-8.62383846e-03 * x) + 4.81577645e+01;
  }

  double powerCoefficient4(double x) {
    return 0.06027056 * exp(-0.01433265 * x) + 0.00140588;
  }

  Function powerCalc(double x) {
    double a = powerCoefficient1(x);
    double b = powerCoefficient2(x);
    double c = powerCoefficient3(x);
    double d = powerCoefficient4(x);

    double func(x) {
      return x*a*log(b*x+2e-1) + x*c*exp(-d*x);
    }

    return func;
  }

  double terrainCalc(String terrain){
    return terrainDunk[terrain] + 0.5*_pinDistance/maxDist;
  }

  void calculate1WDunk(){
    setState(() {
      double hwiCoefficient = dunk1WHWICoefficient(_maxPower);
      Function powerFn = powerCalc(_maxPower);

      double trueDist = _pinDistance + terrainCalc(terrain);
//      print(maxDist);

      double deltaH;
      double inf;
      double variation;
      double elevationInfH;

      if(_elevation >= 0.0){
        deltaH = 0.04656938 * exp(0.02410579 * _elevation) + 0.65046932;
        inf = 3.8;
        variation = 1.0130 + _elevation*0.00009;
      } else {
        deltaH = -0.01628496 * exp(-0.04846523 * _elevation) + 0.70932074;
        inf = _pinDistance / (80 * pow(1.006, (maxDist - _pinDistance)));
        variation = 1.0112;
      }

      deltaH = deltaH * pow(variation, (maxDist - trueDist));

      double realAltitude = _elevation * deltaH;
      double infH = 1 - (realAltitude / inf)/100;

      double hwi = hwiCoefficient * (exp(0.01 * trueDist) - 1);
      double windMovement = hwi * _windSpeed * cos(_windAngle*pi/180) * infH;

      if(_isRadioSelected == true){
        elevationInfH = hwi * _windSpeed * sin(_windAngle*pi/180) * (1-realAltitude*0.016);
        windMovement = windMovement * (1 - elevationInfH*2.75/400);
        print(elevationInfH);
      } else {
        elevationInfH = hwi * _windSpeed * sin(_windAngle*pi/180) * 1.3 * (1-realAltitude*0.013);
        windMovement = windMovement / (1 - elevationInfH*4/625);
      }

      finalMovement = (windMovement + _breaks*1.2/15*hwi/4 + _greenSlope) / 0.218;

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
                              calculate1WDunk();
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
                              calculate1WDunk();
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
                              calculate1WDunk();
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
                              calculate1WDunk();
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
                          calculate1WDunk();
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
                          calculate1WDunk();
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
                              calculate1WDunk();
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Green Slope',
                                hintText: '0'
                            ),
                            keyboardType: TextInputType.number,
                            controller: _greenSlopeController,
                            onChanged: (String value) {
                              greenSlope = value;
                              _greenSlope = double.parse(greenSlope);
                              calculate1WDunk();
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
                      calculate1WDunk();
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
                      calculate1WDunk();
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