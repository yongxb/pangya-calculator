import 'dart:math';
import 'package:pangya_calculator/models/calculatorModels.dart';
import 'package:pangya_calculator/appConfig.dart';

class Calculator3WTomahawk {
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
    double _maxDistTemp = maxPower + 8;
    Function powerFn = powerCalculation(maxPower);
    double _powerCalcMax = powerFn(_maxDistTemp);

    while ((maxPower - _powerCalcMax).abs() > 0.01) {
      _maxDistTemp = _maxDistTemp + (maxPower - _powerCalcMax);
      _powerCalcMax = powerFn(_maxDistTemp);
    }

    maxDist = _maxDistTemp;
  }

  Function hwiCalculation(double x) {
    double a = 1.01259457e-01 * x * exp(-4.49738761e-02 * x) + 1.00380746e-06;
    double b = 7.98944633e-05 * exp(4.40631051e-02 * x) + -1.86333665e+00;
    double c = 1.86337777e-04 * x * exp(-1.22988072e-03 * x) + -2.53551840e-02;

    double func(x) {
      return a * x * (exp(c * x) + b);
    }

    return func;
  }

  Function powerCalculation(double x) {
    double a = 9.27525184e-02 * x * exp(-1.54273038e-02 * x) + 7.23266040e-01;
    double b = -2.70603996e-04 * x * exp(-1.43662129e-02 * x) + 7.71771729e-04;

    double func(x) {
      return x * a * exp(b * x + 2.67489917e-01) + -6.29014783e+01;
    }

    return func;
  }

  Results calculate3WToma(InputData inputs, Results results) {
    maxDistCalc(appData.maxPower3WTomahawk);
    Function hwiFn = hwiCalculation(appData.maxPower3WTomahawk);
    Function powerFn = powerCalculation(appData.maxPower3WTomahawk);

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
      deltaH = 0.542;
      inf = 0.07189109 * exp(0.01121946 * trueDist) + 1.83967384;
      variation = 1.01168;
    } else {
      deltaH = 0.471;
      inf = 6.27787709e-04 * exp(2.15324586e-02 * trueDist) + 2.76937335;
      variation = 1.01114;
    }

    deltaH = deltaH * pow(variation, (maxDist - trueDist));
//    print(deltaH);

    double realAltitude = inputs.elevation * deltaH;
    double infH = 1 - (realAltitude / inf) / 100;
//    print(infH);
    double hwi = hwiFn(trueDist);
    print(hwi);
    double windMovement =
        hwi * inputs.windSpeed * cos(windAngle * pi / 180) * infH;

    if (inputs.windDirection == true) {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle * pi / 180) * 1 * (1 - realAltitude * 0.016);
      windMovement = windMovement * (1 - elevationInfH / 100);
    } else {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle * pi / 180) * 1.25 * (1 - realAltitude * 0.016);
      windMovement = windMovement / (1 - elevationInfH / 100);
    }

    finalMovement =
        (windMovement + inputs.breaks * 1.2 / 15 * hwi / 4) / 0.218;
    results.finalMovement = num.parse(finalMovement.toStringAsFixed(2));

    finalMovementCaliperLeft =
        (0.5 - (finalMovement % 5) / 10) * appData.maxPower3WTomahawk;
    results.finalMovementCaliperLeft =
        num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
    finalMovementCaliperRight =
        (0.5 + (finalMovement % 5) / 10) * appData.maxPower3WTomahawk;
    results.finalMovementCaliperRight =
        num.parse(finalMovementCaliperRight.toStringAsFixed(2));

    finalMovement4 = finalMovement / 4;
    results.finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

    finalMovement4CaliperLeft =
        (0.5 - (finalMovement4 % 5) / 10) * appData.maxPower3WTomahawk;
    results.finalMovement4CaliperLeft =
        num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
    finalMovement4CaliperRight =
        (0.5 + (finalMovement4 % 5) / 10) * appData.maxPower3WTomahawk;
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
