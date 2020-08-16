class AppData {
  static final AppData _appData = new AppData._internal();

  double maxPower1WDunk = 312;
  double maxPower1WTomahawk = 330;
  double maxPower2WTomahawk = 310;
  double maxPower3WTomahawk = 290;
  double maxPower6i = 152;

  bool useCosine = true;
  String angleFunction = 'Cosine';

  double spin = 11;
  String terrain = "100";
  bool windDirection = true;

  factory AppData() {
    return _appData;
  }  AppData._internal();
}

final appData = AppData();

