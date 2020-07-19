import "package:flutter/material.dart";
import "package:pangya_calculator/appConfig.dart";
import "package:shared_preferences/shared_preferences.dart";

class drawerWidget extends StatefulWidget {
  @override
  _drawerWidgetState createState() => _drawerWidgetState();
}

class _drawerWidgetState extends State<drawerWidget> {
  TextEditingController  _maxPower1WDunkController = TextEditingController();
  TextEditingController  _maxPower1WTomahawkController = TextEditingController();
  TextEditingController  _spinController = TextEditingController();

  @override
  void initState() {
    loadMaxPower1W();
    loadSpin();
    loadMaxPower1WPowershot();

    _maxPower1WDunkController.text =  appData.maxPower1WDunk.toString();
    _maxPower1WTomahawkController.text = appData.maxPower1WTomahawk.toString();
    _spinController.text = appData.spin.toString();
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

  loadMaxPower1W() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appData.maxPower1WDunk = (prefs.getDouble('maxPower1WDunk') ?? appData.maxPower1WDunk);
    });
  }

  loadSpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appData.spin = (prefs.getDouble('spin') ?? appData.spin);
    });
  }

  loadMaxPower1WPowershot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appData.maxPower1WTomahawk = (prefs.getDouble('MaxPower1WPowershot') ?? appData.maxPower1WTomahawk);
    });
  }
  updateMaxPower1W() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('maxPower1WDunk', appData.maxPower1WDunk);
    });
  }

  updateMaxPower1WPowershot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('MaxPower1WPowershot', appData.maxPower1WTomahawk);
    });
  }

  updateSpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('spin', appData.spin);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(''),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.settings,
                ),
                Text('Quick Settings'),
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