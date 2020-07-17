import "package:flutter/material.dart";
import 'dart:math';
import 'package:pangya_calculator/Screens/labeledRadio.dart';

class Calculator1WTomaForm extends StatefulWidget {
  @override
  _Calculator1WTomaFormState createState() => _Calculator1WTomaFormState();
}

class _Calculator1WTomaFormState extends State<Calculator1WTomaForm> {
  // Default values
  double caliperPower = 230;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;
  double _maxPower = 291;
  double _pinDistance = 270;
  double _elevation = 0;
  double _windSpeed = 1;
  double _windAngle = 45;
  double _breaks = 0;

  bool _isRadioSelected = true;

  var terrainToma = {"100":0, "98":2, "97":2.35, "95":4, "92":6.4, "90":8.6, "85":13.5, "82":15.2, "80":16.5, "75":21, "70":24.75};
  double maxDist;

  // Initialize Text Fields
  TextEditingController  _maxPowerController = TextEditingController();
  String maxPower = "291";
  TextEditingController  _pinDistanceController = TextEditingController();
  String pinDistance = "270";
  TextEditingController  _elevationController = TextEditingController();
  String elevation = "0";
  TextEditingController  _windSpeedController = TextEditingController();
  String windSpeed = "1";
  TextEditingController  _windAngleController = TextEditingController();
  String windAngle = "45";
  TextEditingController  _breaksController = TextEditingController();
  String breaks = "0";
  TextEditingController  _terrainController = TextEditingController();
  String terrain = "100";

  @override
  void initState() {
    _maxPowerController.text = maxPower;
    _pinDistanceController.text = pinDistance;
    _elevationController.text = elevation;
    _windSpeedController.text = windSpeed;
    _windAngleController.text = windAngle;
    _breaksController.text = breaks;
    _terrainController.text = terrain;

    // initialize max Dist
    maxDistCalc(291.0);
    return super.initState();
  }

  void maxDistCalc(double maxPower) {
    setState(() {
      double _maxDistTemp = maxPower + 4;
      Function powerFn = powerCalculation(maxPower);
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
    _terrainController.dispose();
    super.dispose();
  }

  double hwiCoefficient1(double x) {
    return 1.07285166e-04 * x * exp(-2.13900437e-02 * x) + 4.08252794e-05;
  }

  double hwiCoefficient2(double x) {
    return  5.47801916e-01 * x * exp(-1.93790688e-03 * x) - 7.97470487e+01;
  }

  Function hwiCalculation(double x) {
    double a = hwiCoefficient1(x);
    double b = hwiCoefficient2(x);

    double func(x) {
      return a * x * (exp(1.06715483e-02 * x) + b);
    }

    return func;
  }

  double powerCoefficient1(double x) {
    return 0.03374939 * x * exp(-0.01199168 * x) + 0.80512398;
  }

  double powerCoefficient2(double x) {
    return  -0.00010476 * x * exp(-0.01086175 * x) + 0.00090385;
  }

  Function powerCalculation(double x) {
    double a = powerCoefficient1(x);
    double b = powerCoefficient2(x);

    double func(x) {
      return x*a*exp(b*x);
    }

    return func;
  }

  void calculate1WToma(){
    setState(() {
      Function hwiFn = hwiCalculation(_maxPower);
      Function powerFn = powerCalculation(_maxPower);

      double trueDist = _pinDistance + terrainToma[terrain];
//      print(maxDist);

      double deltaH;
      double inf;
      double variation;
      double elevationInfH;

      if(_elevation >= 0.0){
        deltaH = 0.00150066 * _elevation + 0.67039036;
        inf = -3.06224853e-03  * trueDist + 3.70782116;
        variation = 1.0116;
      } else {
        deltaH = 0.00135027 * _elevation + 0.65443427;
        inf = 0.00306225 * trueDist + 2.09217884;
        variation = 1.012;
      }

      deltaH = deltaH * pow(variation, (maxDist - trueDist));
      print(deltaH);

      double realAltitude = _elevation * deltaH;
      double infH = 1 - (realAltitude / inf)/100;
      print(infH);
      double hwi = hwiFn(trueDist);
      double windMovement = hwi * _windSpeed * cos(_windAngle*pi/180) * infH;

      if(_isRadioSelected == true){
        elevationInfH = hwi * _windSpeed * sin(_windAngle*pi/180) * 0.96 * (1-realAltitude*0.016);
        windMovement = windMovement * (1 - elevationInfH*2.75/400);
      } else {
        elevationInfH = hwi * _windSpeed * sin(_windAngle*pi/180) * 1.23 * (1-realAltitude*0.016);
        windMovement = windMovement / (1 - elevationInfH*4/625);
      }

      finalMovement = (windMovement + _breaks*1.2/15*hwi/4) / 0.218;

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
                              calculate1WToma();
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
                              calculate1WToma();
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
                              calculate1WToma();
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
                              calculate1WToma();
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
                          calculate1WToma();
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
                          calculate1WToma();
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
                              calculate1WToma();
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
                      calculate1WToma();
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
                      calculate1WToma();
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