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
    double a = 1.64811221e-05 * x * exp(-4.01118186e-03 * x) + -1.16932255e-03;
    double b = -1.61781640 * exp(-5.32397936e-01 * x) + 2.39130953;
    double c = 3.70091259e-02 * x * exp(-3.33911099e-02 * x) + 8.37628050e-03;

    double func(x) {
      return a * x * (exp(c * x) + b);
    }

    return func;
  }

  double powerCoefficient1(double x) {
    return 9.63104715e-01 * x * exp(-3.15432932e-03 * x) + -9.56034864e+01;
  }

  double powerCoefficient2(double x) {
    return -3.95003748e-05 * x * exp(-2.42794713e-03 * x) + 6.62168896e-03;
  }

  double powerCoefficient3(double x) {
    return 6.27942619e-01 * x * exp(-3.17735298e-03 * x) + -6.09492974e+01;
  }

  double powerCoefficient4(double x) {
    return -1.04602834e-04 * x * exp(-2.41454016e-03 * x) + 1.75677581e-02;
  }

  Function powerCalc(double x) {
    double a = powerCoefficient1(x);
    double b = powerCoefficient2(x);
    double c = powerCoefficient3(x);
    double d = powerCoefficient4(x);

    double func(x) {
      return x * a * log(b * x + 1.88302988e-01) +
          x * c * exp(-d * x + 8.88891560e-01) +
          2.18079770e-01;
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
        2.93710257e-03 * power * altitude * exp(-2.75777414e-02 * altitude) +
            4.70789691e-02;
    double b =
        2.66856494e-02 * exp(-5.36205172e-03 * altitude) + -1.19168565e-02;
    double c =
        1.45242889e-03 * power * exp(-3.73258966e-02 * altitude) + -2.34931700e-01;
    double d = 8.06498917e-03 * power * exp(-8.27873292e-03 * altitude) +
        -2.29491705e+00;

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
