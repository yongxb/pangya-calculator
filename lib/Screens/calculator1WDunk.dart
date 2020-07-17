import "package:flutter/material.dart";
import 'dart:math';
import 'package:pangya_calculator/Screens/labeledRadio.dart';
import 'package:pangya_calculator/appConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calculator1WDunkForm extends StatefulWidget {
  @override
  _Calculator1WDunkFormState createState() => _Calculator1WDunkFormState();
}

class _Calculator1WDunkFormState extends State<Calculator1WDunkForm> {
  // Initialize Text Fields
  TextEditingController  _pinDistanceController = TextEditingController();
  TextEditingController  _elevationController = TextEditingController();
  TextEditingController  _windSpeedController = TextEditingController();
  TextEditingController  _windAngleController = TextEditingController();
  TextEditingController  _breaksController = TextEditingController();
  TextEditingController  _greenSlopeController = TextEditingController();
  TextEditingController  _terrainController = TextEditingController();

  double caliperPower = 230;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;

//  var terrainDunk = {"100":0, "98":1.31, "97":1.83, "95":3.31, "92":5.13, "90":6.53, "85":10.14, "82":12.4, "80":13.92, "75":18.05, "70":21.53};
  var terrainDunk = {"100":0.0, "98":1.3, "97":1.8, "95":3.3, "92":5.1, "90":6.5, "87":8, "85":10.1, "83":11, "82":12.4, "80":13.9, "75":18.0, "70":21.5};
  double maxDist;

  @override
  void initState() {
    _pinDistanceController.text = appData.pinDistance.toString();
    _elevationController.text = appData.elevation.toString();
    _windSpeedController.text = appData.windSpeed.toString();
    _windAngleController.text = appData.windAngle.toString();
    _breaksController.text = appData.breaks.toString();
    _greenSlopeController.text = appData.greenSlope.toString();
    _terrainController.text = appData.terrain;

    // initialize max Dist
    maxDistCalc(appData.maxPower1WDunk);
    calculate1WDunk();
    super.initState();
    loadMaxPower1W();
  }

  loadMaxPower1W() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appData.maxPower1WDunk = (prefs.getDouble('maxPower1WDunk') ?? appData.maxPower1WDunk);
    });
  }

  void maxDistCalc(double maxPower) {
    setState(() {
      double _maxDistTemp = maxPower - 30;
      Function powerFn = powerCalc(appData.maxPower1WDunk);
      double _powerCalcMax = powerFn(_maxDistTemp);

      while ((appData.maxPower1WDunk - _powerCalcMax).abs() > 0.01){
        _maxDistTemp = _maxDistTemp + (appData.maxPower1WDunk - _powerCalcMax);
        _powerCalcMax = powerFn(_maxDistTemp);
      }

      maxDist = _maxDistTemp;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _pinDistanceController.dispose();
    _elevationController.dispose();
    _windSpeedController.dispose();
    _windAngleController.dispose();
    _breaksController.dispose();
    _greenSlopeController.dispose();
    _terrainController.dispose();
    super.dispose();
  }

  double hwiCoefficient1(double x) {
    return 8.93157081e-04 * x * exp(-2.51729040e-02 * x) + 2.26400028e-04;
  }

  double hwiCoefficient2(double x) {
    return  4.06342095e-01 * x * exp(-2.96413195e-03 * x) - 4.82573224e+01;
  }

  Function hwiCalculation(double x) {
    double a = hwiCoefficient1(x);
    double b = hwiCoefficient2(x);

    double func(x) {
      return a * x * (exp(8.30546152e-03 * x) + b);
    }

    return func;
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
    double terrainEffect = 0;
    if(terrain != "100") {
      terrainEffect = terrainDunk[terrain] + 0.5 * appData.pinDistance / maxDist;
    }
    return terrainEffect;
  }

  void calculate1WDunk(){
    setState(() {
      Function hwiFn = hwiCalculation(appData.maxPower1WDunk);
      Function powerFn = powerCalc(appData.maxPower1WDunk);

      double trueDist = appData.pinDistance + terrainCalc(appData.terrain);
      print(trueDist);

      double windAngle = appData.windAngle;

      if (appData.useCosine == false){
        windAngle = 90 - windAngle;
      }

      double deltaH;
      double inf;
      double variation;
      double elevationInfH;

      if(appData.elevation >= 0.0){
        deltaH = 0.04656938 * exp(0.02410579 * appData.elevation) + 0.65046932;
        inf = 3.8;
        variation = 1.0130 + appData.elevation*0.00009;
      } else {
        deltaH = -0.01628496 * exp(-0.04846523 * appData.elevation) + 0.70932074;
        inf = appData.pinDistance / (80 * pow(1.006, (maxDist - appData.pinDistance)));
        variation = 1.0112;
      }

      deltaH = deltaH * pow(variation, (maxDist - trueDist));

      double realAltitude = appData.elevation * deltaH;
      double infH = 1 - (realAltitude / inf)/100;

      double hwi = hwiFn(trueDist);
      double windMovement = hwi * appData.windSpeed * cos(windAngle*pi/180) * infH;

      if(appData.windDirection == true){
        elevationInfH = hwi * appData.windSpeed * sin(windAngle*pi/180) * (1-realAltitude*0.016);
        windMovement = windMovement * (1 - elevationInfH*2.75/400);
        print(elevationInfH);
      } else {
        elevationInfH = hwi * appData.windSpeed * sin(windAngle*pi/180) * 1.3 * (1-realAltitude*0.013);
        windMovement = windMovement / (1 - elevationInfH*4/625);
      }

      finalMovement = (windMovement + appData.breaks*1.2/15*hwi/4 + appData.greenSlope) / 0.218;

      finalMovement = num.parse(finalMovement.toStringAsFixed(2));
      finalMovementCaliperLeft = (0.5 - (finalMovement % 5) / 10) * appData.maxPower1WDunk;
      finalMovementCaliperLeft = num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
      finalMovementCaliperRight = (0.5 + (finalMovement % 5) / 10) * appData.maxPower1WDunk;
      finalMovementCaliperRight = num.parse(finalMovementCaliperRight.toStringAsFixed(2));

      finalMovement4 = finalMovement / 4;
      finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

      finalMovement4CaliperLeft = (0.5 - (finalMovement4 % 5) / 10) * appData.maxPower1WDunk;
      finalMovement4CaliperLeft = num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
      finalMovement4CaliperRight = (0.5 + (finalMovement4 % 5) / 10) * appData.maxPower1WDunk;
      finalMovement4CaliperRight = num.parse(finalMovement4CaliperRight.toStringAsFixed(2));

      double force;
      if(appData.windDirection == true) {
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
                      child: Text('Caliper power (Max Power: ${appData.maxPower1WDunk} | Terrain: ${appData.terrain})', textAlign: TextAlign.left,),
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
                              appData.pinDistance = double.parse(value);
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
                              appData.elevation = double.parse(value);
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
                              appData.windSpeed = double.parse(value);
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
                              appData.windAngle = double.parse(value);
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
                          child: Text("Wind Direction (${appData.angleFunction}):",textAlign: TextAlign.left,),
                        ),
                      ),
                      LabeledRadio(
                        label: 'Forward',
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        value: true,
                        groupValue: appData.windDirection,
                        onChanged: (bool newValue) {
                          setState(() {
                            appData.windDirection = newValue;
                          });
                          calculate1WDunk();
                        },
                      ),
                      LabeledRadio(
                        label: 'Backward',
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        value: false,
                        groupValue: appData.windDirection,
                        onChanged: (bool newValue) {
                          setState(() {
                            appData.windDirection = newValue;
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
                              appData.breaks = double.parse(value);
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
                              appData.greenSlope = double.parse(value);
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
                      appData.terrain = value;
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