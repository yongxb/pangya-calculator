class Results{
  static final _results = new Results._internal();

  double caliperPower = 230;
  double finalMovement = 0;
  double finalMovement4 = 0;
  double finalMovementCaliperLeft;
  double finalMovementCaliperRight;
  double finalMovement4CaliperLeft;
  double finalMovement4CaliperRight;

  factory Results() {
    return _results;
  }  Results._internal();
}

class InputData{
  static final _inputs = new InputData._internal();

  double pinDistance = 230.0;
  double elevation = 0;
  double windSpeed = 1;
  double windAngle = 45;
  double breaks = 0;
  double greenSlope = 0;
  double spin = 11;
  String terrain = "100";
  bool windDirection = true;

  factory InputData() {
    return _inputs;
  }  InputData._internal();
}