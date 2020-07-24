import 'dart:math';
import 'package:pangya_calculator/models/calculatorModels.dart';
import 'package:pangya_calculator/appConfig.dart';

class Calculator1WTomahawk {
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
    double _maxDistTemp = maxPower + 4;
    Function powerFn = powerCalculation(maxPower);
    double _powerCalcMax = powerFn(_maxDistTemp);

    while ((maxPower - _powerCalcMax).abs() > 0.01) {
      _maxDistTemp = _maxDistTemp + (maxPower - _powerCalcMax);
      _powerCalcMax = powerFn(_maxDistTemp);
    }

    maxDist = _maxDistTemp;
  }

  double hwiCoefficient1(double x) {
    return 1.07285166e-04 * x * exp(-2.13900437e-02 * x) + 4.08252794e-05;
  }

  double hwiCoefficient2(double x) {
    return 5.47801916e-01 * x * exp(-1.93790688e-03 * x) - 7.97470487e+01;
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
    return -0.00010476 * x * exp(-0.01086175 * x) + 0.00090385;
  }

  Function powerCalculation(double x) {
    double a = powerCoefficient1(x);
    double b = powerCoefficient2(x);

    double func(x) {
      return x * a * exp(b * x);
    }

    return func;
  }

  Results calculate1WToma(InputData inputs, Results results) {
    maxDistCalc(appData.maxPower1WTomahawk);
    Function hwiFn = hwiCalculation(appData.maxPower1WTomahawk);
    Function powerFn = powerCalculation(appData.maxPower1WTomahawk);

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
      deltaH = 0.00150066 * inputs.elevation + 0.67039036;
      inf = -3.06224853e-03 * trueDist + 3.70782116;
      variation = 1.0116;
    } else {
      deltaH = 0.00135027 * inputs.elevation + 0.65443427;
      inf = 0.00306225 * trueDist + 2.09217884;
      variation = 1.012;
    }

    deltaH = deltaH * pow(variation, (maxDist - trueDist));
    print(deltaH);

    double realAltitude = inputs.elevation * deltaH;
    double infH = 1 - (realAltitude / inf) / 100;
    print(infH);
    double hwi = hwiFn(trueDist);
    double windMovement =
        hwi * inputs.windSpeed * cos(inputs.windAngle * pi / 180) * infH;

    if (inputs.windDirection == true) {
      elevationInfH = hwi *
          inputs.windSpeed *
          sin(inputs.windAngle * pi / 180) *
          0.96 *
          (1 - realAltitude * 0.016);
      windMovement = windMovement * (1 - elevationInfH * 2.75 / 400);
    } else {
      elevationInfH = hwi *
          inputs.windSpeed *
          sin(inputs.windAngle * pi / 180) *
          1.23 *
          (1 - realAltitude * 0.016);
      windMovement = windMovement / (1 - elevationInfH * 4 / 625);
    }

    finalMovement =
        (windMovement + inputs.breaks * 1.2 / 15 * hwi / 4) / 0.218;
    results.finalMovement = num.parse(finalMovement.toStringAsFixed(2));

    finalMovementCaliperLeft =
        (0.5 - (finalMovement % 5) / 10) * appData.maxPower1WTomahawk;
    results.finalMovementCaliperLeft =
        num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
    finalMovementCaliperRight =
        (0.5 + (finalMovement % 5) / 10) * appData.maxPower1WTomahawk;
    results.finalMovementCaliperRight =
        num.parse(finalMovementCaliperRight.toStringAsFixed(2));

    finalMovement4 = finalMovement / 4;
    results.finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

    finalMovement4CaliperLeft =
        (0.5 - (finalMovement4 % 5) / 10) * appData.maxPower1WTomahawk;
    results.finalMovement4CaliperLeft =
        num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
    finalMovement4CaliperRight =
        (0.5 + (finalMovement4 % 5) / 10) * appData.maxPower1WTomahawk;
    results.finalMovement4CaliperRight =
        num.parse(finalMovement4CaliperRight.toStringAsFixed(2));

    double force;
    if (appData.windDirection == true) {
      force = trueDist + realAltitude - elevationInfH;
    } else {
      force = trueDist + realAltitude + elevationInfH;
    }
    caliperPower = powerFn(force);
    results.caliperPower = num.parse(caliperPower.toStringAsFixed(2));

    return results;
  }
}
