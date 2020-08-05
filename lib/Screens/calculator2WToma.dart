import 'dart:math';
import 'package:pangya_calculator/models/calculatorModels.dart';
import 'package:pangya_calculator/appConfig.dart';

class Calculator2WTomahawk {
  // Default values
  double caliperPower = 230;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;

  var terrainToma = {
    "100": 0,
    "98": 2,
    "97": 2.35,
    "95": 4,
    "92": 6.4,
    "90": 8.6,
    "87": 11,
    "85": 13.5,
    "84": 14.3,
    "82": 15.2,
    "80": 16.5,
    "75": 21,
    "70": 24.75
  };
  double maxDist;

  void maxDistCalc(double maxPower) {
    double _maxDistTemp = maxPower + 6;
    Function powerFn = powerCalculation(maxPower);
    double _powerCalcMax = powerFn(_maxDistTemp);

    while ((maxPower - _powerCalcMax).abs() > 0.01) {
      _maxDistTemp = _maxDistTemp + (maxPower - _powerCalcMax);
      _powerCalcMax = powerFn(_maxDistTemp);
    }

    maxDist = _maxDistTemp;
  }

  Function hwiCalculation(double x) {
    double a = 4.63627595e-03 * x * exp(-3.46995598e-02 * x) + 4.13034531e-04;
    double b = 3.65077498e-02 * exp(-7.90550052e-02 * x) + 5.41663842e-01;
    double c = 4.70120674e-04 * x * exp(-3.60246506e-03 * x) + -4.09828877e-02;

    double func(x) {
      return a * x * (exp(c * x) + b);
    }

    return func;
  }

  Function powerCalculation(double x) {
    double a = 3.59290203e-02 * x * exp(-1.10884798e-02 * x) + 6.33358542e-01;
    double b = -1.27744557e-04 * x * exp(-1.07969335e-02 * x) + 1.07415009e-03;

    double func(x) {
      return x * a * exp(b * x + 2.12391612e-01) + -3.96578023e+01;
    }

    return func;
  }

  Results calculate2WToma(InputData inputs, Results results) {
    maxDistCalc(appData.maxPower2WTomahawk);
    Function hwiFn = hwiCalculation(appData.maxPower2WTomahawk);
    Function powerFn = powerCalculation(appData.maxPower2WTomahawk);

    double trueDist = inputs.pinDistance + terrainToma[inputs.terrain];
//      print(maxDist);

    double windAngle = inputs.windAngle;

    if (appData.useCosine == false) {
      windAngle = 90 - windAngle;
    }

    double deltaH;
    double inf;
    double variation;
    double elevationInfH;

    if (inputs.elevation >= 0.0) {
      deltaH = 0.576;
      inf = 3.6;
      variation = 1.011;
    } else {
      deltaH = -0.01840853 * exp(-0.04497535 * inputs.elevation) + 0.56025536;
      inf = 0.01590355 * exp(0.01546865 * trueDist) + 2.14618127;
      variation = 1.011;
    }

    print(deltaH);
    deltaH = deltaH * pow(variation, (maxDist - trueDist));

    double realAltitude = inputs.elevation * deltaH;
    double infH = 1 - (realAltitude / inf) / 100;
    print(infH);
    double hwi = hwiFn(trueDist);
    print(hwi);
    double windMovement =
        hwi * inputs.windSpeed * cos(windAngle * pi / 180) * infH;

    if (inputs.windDirection == true) {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle * pi / 180) * 1 * (1 - realAltitude * 0.016);
      windMovement = windMovement * (1 - elevationInfH * 2.75 / 400);
    } else {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle * pi / 180) * 1.27 * (1 - realAltitude * 0.016);
      windMovement = windMovement / (1 - elevationInfH * 4 / 625);
    }

    finalMovement =
        (windMovement + inputs.breaks * 1.2 / 15 * hwi / 4) / 0.218;
    results.finalMovement = num.parse(finalMovement.toStringAsFixed(2));

    finalMovementCaliperLeft =
        (0.5 - (finalMovement % 5) / 10) * appData.maxPower2WTomahawk;
    results.finalMovementCaliperLeft =
        num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
    finalMovementCaliperRight =
        (0.5 + (finalMovement % 5) / 10) * appData.maxPower2WTomahawk;
    results.finalMovementCaliperRight =
        num.parse(finalMovementCaliperRight.toStringAsFixed(2));

    finalMovement4 = finalMovement / 4;
    results.finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

    finalMovement4CaliperLeft =
        (0.5 - (finalMovement4 % 5) / 10) * appData.maxPower2WTomahawk;
    results.finalMovement4CaliperLeft =
        num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
    finalMovement4CaliperRight =
        (0.5 + (finalMovement4 % 5) / 10) * appData.maxPower2WTomahawk;
    results.finalMovement4CaliperRight =
        num.parse(finalMovement4CaliperRight.toStringAsFixed(2));

    double force;
    if (inputs.windDirection == true) {
      force = trueDist + realAltitude - elevationInfH;
    } else {
      force = trueDist + realAltitude + elevationInfH;
    }
    caliperPower = powerFn(force);
    results.caliperPower = num.parse(caliperPower.toStringAsFixed(2));

    return results;
  }
}
