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

//  var terrainDunk = {"100":1, "98":1/0.98, "97":1/0.97, "95":1/0.95, "92":1/0.92, "90":1/0.9, "87":1/0.87, "85":1/0.85, "83":1/0.83, "82":1/0.82, "80":1/0.8, "75":1/0.75};
  var terrainDunk = {"100":1, "98":1.02, "97":1.03, "95":1.05, "92":1.08, "90":1.1, "87":1.13, "85":1.17, "82":1.18, "80":1.2, "75":1.25};

  double powerFn(double x){
    return x*6.46943169e+01*log(-6.36034455e-04*x+4.56435640e-01) + x*5.16857848e+01*exp(1.80631663e-03*x);
  }

  Results calculateDunk6i(InputData inputs, Results results) {
    double trueDist = inputs.pinDistance * terrainDunk[inputs.terrain];

    double windAngle = inputs.windAngle;
    double realAltitude;

    if (appData.useCosine == false) {
      windAngle = 90 - windAngle;
    }

    double deltaH;
    double inf;
    double variation;
    double elevationInfH;

    if (inputs.elevation >= 0){
      realAltitude = 1.5125 * exp(0.54654371 * inputs.elevation) + -1.5125;
    } else {
      realAltitude = inputs.elevation;
    }

    double hwi = 4.54804977e-01 * trueDist * (exp(8.84821388e-06 * trueDist) + -9.86679938e-01);

    double windMovement = hwi * inputs.windSpeed * cos(windAngle*pi/180);

    if(inputs.windDirection == true){
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle*pi/180) * (1 - realAltitude * 0.016);
    } else {
      elevationInfH = hwi * inputs.windSpeed * sin(windAngle*pi/180) * (1 - realAltitude * 0.016);
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