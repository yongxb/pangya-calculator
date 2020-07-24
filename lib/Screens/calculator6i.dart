import 'dart:math';
import 'package:pangya_calculator/models/calculatorModels.dart';
import 'package:pangya_calculator/appConfig.dart';

class Calculator6i {
  double caliperPower = 141;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;

  double maxDist;

  var terrainDunk = {"100":1, "98":1/0.98, "97":1/0.97, "95":1/0.95, "92":1/0.92, "90":1/0.9, "87":1/0.87, "85":1/0.85, "83":1/0.83, "82":1/0.82, "80":1/0.8, "75":1/0.75};
//  var terrainDunk = {"100":1, "98":1.02, "97":1.03, "95":1.05, "92":1.08, "90":1.1, "87":1.13, "85":1.16, "82":1.18, "80":1.2, "75":1.25};

  double powerFn(double x){
    return x*0.32849496*log(1.05924966*x+1e-6) + x*0.71896443*exp(-0.07405188*x);
  }

  void maxDistCalc(double maxPower) {
    double _maxDistTemp = maxPower - 18;
    double _powerCalcMax = powerFn(_maxDistTemp);

    while ((maxPower - _powerCalcMax).abs() > 0.01){
      _maxDistTemp = _maxDistTemp + (maxPower - _powerCalcMax);
      _powerCalcMax = powerFn(_maxDistTemp);
    }

    maxDist = _maxDistTemp;
  }

  Results calculateDunk6i(InputData inputs, Results results) {
    maxDistCalc(appData.maxPower6i);
    double hwiCoefficient = 0.477;

    double trueDist = inputs.pinDistance * terrainDunk[inputs.terrain];

    double windAngle = inputs.windAngle;

    if (appData.useCosine == false) {
      windAngle = 90 - windAngle;
    }

    double deltaH;
    double inf;
    double variation;
    double elevationInfH;

    if(inputs.elevation >= 0.0){
      deltaH = 0.04656938 * exp(0.02410579 * inputs.elevation) + 0.65046932;
      inf = 3.8;
      variation = 1.002;
    } else {
      deltaH = -0.01628496 * exp(-0.04846523 * inputs.elevation) + 0.70932074;
      inf = 3.2;
      variation = 1.0015;
    }

    deltaH = deltaH * pow(variation, (maxDist - trueDist));

    double realAltitude = inputs.elevation * deltaH;
    double infH = 1 - (realAltitude / inf)/100;

    print(realAltitude);
    double hwi = hwiCoefficient * (exp(0.01 * trueDist) - 1);
    double windMovement = hwi * inputs.windSpeed * cos(windAngle*pi/180) * infH;

    if(inputs.windDirection == true){
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle*pi/180) * (1-realAltitude*0.016);
      windMovement = windMovement * (1 - elevationInfH*2.75/400);
    } else {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle*pi/180) * 1.3 * (1-realAltitude*0.013);
      windMovement = windMovement / (1 - elevationInfH*4/625);
    }

    finalMovement = (windMovement + inputs.breaks*hwi/4) / 0.218;
    results.finalMovement = num.parse(finalMovement.toStringAsFixed(2));
    finalMovementCaliperLeft = (0.5 - (finalMovement % 5) / 10) * appData.maxPower6i;
    results.finalMovementCaliperLeft = num.parse(finalMovementCaliperLeft.toStringAsFixed(2));
    finalMovementCaliperRight = (0.5 + (finalMovement % 5) / 10) * appData.maxPower6i;
    results.finalMovementCaliperRight = num.parse(finalMovementCaliperRight.toStringAsFixed(2));

    finalMovement4 = finalMovement / 4;
    results.finalMovement4 = num.parse(finalMovement4.toStringAsFixed(2));

    finalMovement4CaliperLeft = (0.5 - (finalMovement4 % 5) / 10) * appData.maxPower6i;
    results.finalMovement4CaliperLeft = num.parse(finalMovement4CaliperLeft.toStringAsFixed(2));
    finalMovement4CaliperRight = (0.5 + (finalMovement4 % 5) / 10) * appData.maxPower6i;
    results.finalMovement4CaliperRight = num.parse(finalMovement4CaliperRight.toStringAsFixed(2));

    double force;
    if(inputs.windDirection == true) {
      force = trueDist + realAltitude - elevationInfH;
    } else {
      force = trueDist + realAltitude + elevationInfH;
    }

    caliperPower = powerFn(force);
    results.caliperPower = num.parse(caliperPower.toStringAsFixed(2));

    return results;
  }
}