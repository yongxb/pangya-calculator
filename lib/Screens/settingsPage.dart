import "package:flutter/material.dart";
import "package:pangya_calculator/appConfig.dart";
import "package:shared_preferences/shared_preferences.dart";

class SettingsPage extends StatefulWidget {
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController  _maxPower1WDunkController = TextEditingController();
  TextEditingController  _maxPower1WTomahawkController = TextEditingController();
  TextEditingController  _spinController = TextEditingController();

  @override
  void initState() {
    Future<double> initMaxPower1W = loadMaxPower1W();
    Future<double> initSpin = loadSpin();
    Future<double> initMaxPower1WPowershot = loadMaxPower1WPowershot();

    initMaxPower1W.then((value) {
      _maxPower1WDunkController.text =  appData.maxPower1WDunk.toString();
    });

    initMaxPower1WPowershot.then((value){
      _maxPower1WTomahawkController.text = value.toString();
    });

    initSpin.then((value) {
      _spinController.text = appData.spin.toString();
    });
    return super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _maxPower1WDunkController.dispose();
    _maxPower1WTomahawkController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Future<double> loadMaxPower1W() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    appData.maxPower1WDunk = (prefs.getDouble('maxPower1WDunk') ?? appData.maxPower1WDunk);
    return appData.maxPower1WDunk;
  }

  Future<double> loadSpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    appData.spin = (prefs.getDouble('spin') ?? appData.spin);
    return appData.spin;
  }

  Future<double> loadMaxPower1WPowershot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    appData.maxPower1WTomahawk = (prefs.getDouble('MaxPower1WPowershot') ?? appData.maxPower1WTomahawk);
    appData.maxPower2WTomahawk = appData.maxPower1WTomahawk - 20;
    return appData.maxPower1WTomahawk;
  }

  updateMaxPower1W() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("okay");
    prefs.setDouble('maxPower1WDunk', appData.maxPower1WDunk);
  }

  updateMaxPower1WPowershot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('MaxPower1WPowershot', appData.maxPower1WTomahawk);
  }

  updateSpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('spin', appData.spin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'),
      ),
      body: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 8),
            child: Row(
                children: <Widget>[
                  Icon(
                    Icons.settings,
                  ),
                  Text('Power settings'),
                ]
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '1W Max Power',
                hintText: '280',
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
              ),
              keyboardType: TextInputType.number,
              controller: _maxPower1WDunkController,
              onChanged: (String value) {
                appData.maxPower1WDunk = double.parse(value);
                updateMaxPower1W();
//                context.bloc<CalculatorBloc>().add(CalculatorEvent(EventType.updatePinDistance, value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '1W Tomahawk Max Power',
                hintText: '290',
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
              ),
              keyboardType: TextInputType.number,
              controller: _maxPower1WTomahawkController,
              onChanged: (String value) {
                appData.maxPower1WTomahawk = double.parse(value);
                appData.maxPower2WTomahawk = appData.maxPower1WTomahawk-20;
                updateMaxPower1WPowershot();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Spin',
                hintText: '9',
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
              ),
              keyboardType: TextInputType.number,
              controller: _spinController,
              onChanged: (String value) {
                appData.spin = double.parse(value);
                updateSpin();
              },
            ),
          ),
          CheckboxListTile(
            title: const Text("Use Cosine"),
            value: appData.useCosine,
            onChanged: (bool value){
              setState(() {
                appData.useCosine = !appData.useCosine;
                if(appData.useCosine == false){
                  appData.angleFunction = 'Sine';
                } else {
                  appData.angleFunction = 'Cosine';
                }
              });
            },
          )
        ],
      ),
    );
  }
}