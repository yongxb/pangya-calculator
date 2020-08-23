import 'dart:math';
import 'package:pangya_calculator/appConfig.dart';
import 'package:pangya_calculator/models/calculatorModels.dart';

class Calculator1WDunk {
  double caliperPower = 230;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;

//  var terrainDunk = {"100":0, "98":1.31, "97":1.83, "95":3.31, "92":5.13, "90":6.53, "85":10.14, "82":12.4, "80":13.92, "75":18.05, "70":21.53};
  var terrainDunk = {
    "100": 0.0,
    "98": 1.3,
    "97": 1.8,
    "95": 3.3,
    "92": 5.1,
    "90": 6.5,
    "87": 8,
    "85": 10.1,
    "83": 11,
    "82": 12.4,
    "80": 13.9,
    "75": 18.0,
    "70": 21.5
  };
  double maxDist;

  void maxDistCalc(double maxPower) {
    double _maxDistTemp = maxPower - 30;
    Function powerFn = powerCalc(appData.maxPower1WDunk);
    double _powerCalcMax = powerFn(_maxDistTemp);

    while ((appData.maxPower1WDunk - _powerCalcMax).abs() > 0.01) {
      _maxDistTemp = _maxDistTemp + (appData.maxPower1WDunk - _powerCalcMax);
      _powerCalcMax = powerFn(_maxDistTemp);
    }

    maxDist = _maxDistTemp;
  }

  Function hwiCalculation(double x) {
    double a = 1.25193986e-05 * x * exp(-4.47219643e-03 * x) + -6.68201024e-04;
    double b = -5.85884135e-02 * exp(-2.79831405e-01 * x) + 2.35765814;
    double c = 7.46743201e-02 * x * exp(-3.68194377e-02 * x) + 8.55486513e-03;

    double func(x) {
      return a * x * (exp(c * x) + b);
    }

    return func;
  }

  Function powerCalc(double z) {
    double a = -2.24346577e-09*z + -2.29176914e-05;
    double b = -1.36652216e-04*z + 1.86588256e+00;
    double c = -3.68084924e-02*z + -2.44174783e+00;
    double d = -1.59993123e-02*z + 2.83877412e+01;
    double e = -1.04489568e-04*z + 2.70617095e-02;
    double f = -5.95414353e-03*z + 2.35411877e+00;
    double g = -2.20752053e-06*z + -4.18134175e+00;
    double h = -4.07657596e-09*z + 2.47494006e-06;
    double i = 5.78608144e-12*z + -2.42421922e-09;

    double func(x) {
      return a*(sqrt(b*x)+c)*pow((x+d),3) + e*pow(x,2) + f*x + g + h*pow(x,4) + i*pow(x,5);
    }

    return func;
  }

  double terrainCalc(String terrain, double pinDistance) {
    double terrainEffect = 0;
    if (terrain != "100") {
      terrainEffect = terrainDunk[terrain] + 0.5 * pinDistance / maxDist;
    }
    return terrainEffect;
  }

  double elevationCalc(double altitude, double trueDist) {
    double diffDistance = maxDist - trueDist;
    double power = appData.maxPower1WDunk;

    double a =
        8.13996257e-04 * power * altitude * exp(-5.56877459e-03 * altitude) +
            1.71973674e-03;
    double b =
        1.08999155e-01 * exp(-1.16798652e-04 * altitude) + -9.25253986e-02;
    double c =
        9.95579689e-04 * power * exp(-7.82812304e-03 * altitude) + -2.33253108e-01;
    double d = 4.07782643e-05 * power * exp(1.09862392e-01 * altitude) +
        -1.15331497e+00;

    return a / (exp(-b * diffDistance + d) + c);
  }

  Results calculate1WDunk(InputData inputs, Results results) {
    maxDistCalc(appData.maxPower1WDunk);
    Function hwiFn = hwiCalculation(appData.maxPower1WDunk);
    Function powerFn = powerCalc(appData.maxPower1WDunk);

    double trueDist =
        inputs.pinDistance + terrainCalc(inputs.terrain, inputs.pinDistance);

    double windAngle = inputs.windAngle;

    if (appData.useCosine == false) {
      windAngle = 90 - windAngle;
    }

    double inf;
    double elevationInfH;

    if (inputs.elevation >= 0.0) {
      inf = 3.3;
    } else {
      inf = inputs.pinDistance /
          (80 * pow(1.006, (maxDist - inputs.pinDistance)));
    }
//    print(inputs.pinDistance / (80 * pow(1.006, (maxDist - inputs.pinDistance))));
    double realAltitude = elevationCalc(inputs.elevation, trueDist);
//    realAltitude = 27.74;
    print(maxDist);

    double infH = 1 - (realAltitude / inf) / 100;

    double hwi = hwiFn(trueDist);
    double windMovement =
        hwi * inputs.windSpeed * cos(windAngle * pi / 180) * infH;

    if (inputs.windDirection == true) {
      elevationInfH = hwi *
          inputs.windSpeed *
          sin(windAngle * pi / 180) *
          (1 - realAltitude * 0.016);
      windMovement = windMovement * (1 - elevationInfH * 2.75 / 400);
//        print(elevationInfH);
    } else {
      elevationInfH = hwi *
          inputs.windSpeed *
          sin(windAngle * pi / 180) *
          1.3 * (1 - realAltitude * 0.013);
      windMovement = windMovement / (1 - elevationInfH * 4 / 625);
    }

    finalMovement = (windMovement +
            inputs.breaks * 1.2 / 15 * hwi / 4 +
            inputs.greenSlope) /
        0.218;
    results.finalMovement = num.parse(finalMovement.toStringAsFixed(2));

    finalMovementCaliperLeft =
        (0.5 - (finalMovement % 5) / 10) * appData.maxPower1WDunk;
    results.finalMovementCaliperLeft =
        num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
    finalMovementCaliperRight =
        (0.5 + (finalMovement % 5) / 10) * appData.maxPower1WDunk;
    results.finalMovementCaliperRight =
        num.parse(finalMovementCaliperRight.toStringAsFixed(2));

    finalMovement4 = finalMovement / 4;
    results.finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

    finalMovement4CaliperLeft =
        (0.5 - (finalMovement4 % 5) / 10) * appData.maxPower1WDunk;
    results.finalMovement4CaliperLeft =
        num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
    finalMovement4CaliperRight =
        (0.5 + (finalMovement4 % 5) / 10) * appData.maxPower1WDunk;
    results.finalMovement4CaliperRight =
        num.parse(finalMovement4CaliperRight.toStringAsFixed(2));

    double force;
    if (inputs.windDirection == true) {
      force = trueDist + realAltitude - elevationInfH;
    } else {
      force = trueDist + realAltitude + elevationInfH;
    }

    //spin correction
    double spinCorrection = 0.4 *
        (11 - appData.spin) *
        (1 + (maxDist - appData.maxPower1WDunk) / appData.maxPower1WDunk) /
        appData.maxPower1WDunk *
        trueDist *
        exp((0.4 + 0.0008 * appData.maxPower1WDunk) /
            appData.maxPower1WDunk *
            trueDist);

    caliperPower = powerFn(force + spinCorrection);
    results.caliperPower = num.parse(caliperPower.toStringAsFixed(2));

    return results;
  }
}
