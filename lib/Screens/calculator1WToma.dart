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

  Function hwiCalculation(double x) {
    var arr = [9.77558241e-05, -1.92731919e-02,  8.22361023e-05, -6.19247355e-01,
      -1.27292693e-02,  8.76395408e+00,  9.04416176e-03];
    double a = arr[0] * x * exp(arr[1] * x) + arr[2];
    double b = arr[3] * x * exp(arr[4] * x) + arr[5];

    double func(x) {
      return a * x * (exp(arr[6] * x) + b);
    }

    return func;
  }

  Function powerCalculation(double z) {
    double a = 3.49429848e-01*z + -1.35184966e+02 ;
    double b = 1.30756937e-03*z + 6.45524703e-01;
    double c = -6.21313283e-01*z + 1.92626005e+02;
    double d = -4.18039149e-04*z + 2.11026210e-01;
    double e = -3.65710482e-04*z + 9.21842280e-02;

    double func(x) {
      return a * (d*x - sqrt(x)) / (e*x + sqrt(x)) + b*x + c;
    }

    return func;
  }

  double elevationCalc(double altitude, double trueDist) {
    double diffDistance = maxDist - trueDist;
    double power = appData.maxPower1WTomahawk;

    double a =
        3.86488409e-03 * power * altitude * exp( -5.80707572e-03 * altitude) +
        -1.90547111e-01;
    double b =
         6.39048949e-11 * exp(-2.42093180e-01* altitude) + 1.35797420e-02;
    double c =
         1.77718851e-03 * power * exp( -1.10287723e-02 * altitude) + -2.82900019e-01;
    double d = 6.40639887e-03 * power * exp(-2.49761481e-03 * altitude) +
        -1.47028152e+00;

    return a / (exp(-b * diffDistance + d) + c);
  }

//  double elevationHWICalc(double altitude, double trueDist) {
//    double diffDistance = maxDist - trueDist;
//    double power = appData.maxPower1WTomahawk;
//
//    double a =
//        2.13655008e-05 * power * altitude * exp( 9.43098646e-02 * altitude) +
//            1.22844778e-02;
//    double b =
//        -1.08112889e-02 * exp(-3.53214423e-04* altitude) + 1.09327610e-02;
//    double c =
//        -8.83546524e-04 * power * exp( 5.99660431e-01 * altitude) + -1.04396752e+00;
//    double d = 5.69018396e-03 * power * exp(9.47784992e-02 * altitude) +
//        -6.10914424e-02;
//
//    return a / (exp(-b * diffDistance + d) + c);
//  }

  double elevationHWICalc(double altitude, double trueDist) {
    double diffDistance = maxDist - trueDist;
    double power = appData.maxPower1WTomahawk;

    double a =
        6.06179237e-05 * power * altitude * exp(-1.47616307e-01 * altitude) +
            3.26947118e-02;
    double b =
        1.77392322e-07 * exp(9.58161194e-01* altitude) + 1.54887042e-04;
    double c =
        -1.50635800e-03 * power * exp(-3.38755014e-01 * altitude) + 1.67287979e+00;
    double d = 1.15368003e-02 * power * exp(-3.37191922e-02 * altitude) +
        -1.38429892e+00;

    return a / (exp(-b * diffDistance + d) + c);
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
    double elevationInfH;
    double inf;

    if (inputs.elevation >= 0.0) {
      inf = -3.06224853e-03 * trueDist + 3.70782116;
    } else {
      inf = 0.00306225 * trueDist + 2.09217884;
    }

    double realAltitude = elevationCalc(inputs.elevation, trueDist);
    double infH = 1 - (realAltitude / inf) / 100;
    print(infH);
    double hwi = hwiFn(trueDist);
    double windMovement =
        hwi * inputs.windSpeed * cos(windAngle * pi / 180) * infH;
//    double realAltitude = elevationCalc(inputs.elevation, trueDist);
//    double hwi = hwiFn(trueDist) - elevationHWICalc(inputs.elevation, trueDist);
//    double windMovement = hwi * inputs.windSpeed * cos(windAngle * pi / 180);
//    print(hwi);
//    print(hwiFn(trueDist));

    if (inputs.windDirection == true) {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle * pi / 180) * 0.96 * (1 - realAltitude * 0.016);
      windMovement = windMovement * (1 - elevationInfH * 2.75 / 400);
    } else {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle * pi / 180) * 1.23 * (1 - realAltitude * 0.016);
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
