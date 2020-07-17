class AppData {
  static final AppData _appData = new AppData._internal();

  String text;

  double maxPower1WDunk = 281;
  double maxPower1WTomahawk = 291;
  double maxPower6i = 141;

  bool useCosine = true;
  String angleFunction = 'Cosine';

  double pinDistance = 220;
  double elevation = 0;
  double windSpeed = 1;
  double windAngle = 45;
  double breaks = 0;
  double greenSlope = 0;
  String terrain = "100";
  bool windDirection = true;

  factory AppData() {
    return _appData;
  }  AppData._internal();
}

final appData = AppData();