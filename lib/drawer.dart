import "package:flutter/material.dart";
import "package:pangya_calculator/appConfig.dart";

class drawerWidget extends StatefulWidget {
  @override
  _drawerWidgetState createState() => _drawerWidgetState();
}

class _drawerWidgetState extends State<drawerWidget> {
  TextEditingController  _maxPower1WDunkController = TextEditingController();
  TextEditingController  _maxPower1WTomahawkController = TextEditingController();

  @override
  void initState() {
    _maxPower1WDunkController.text = appData.maxPower1WDunk.toString();
    _maxPower1WTomahawkController.text = appData.maxPower1WTomahawk.toString();

    return super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _maxPower1WDunkController.dispose();
    _maxPower1WTomahawkController.dispose();
    super.dispose();
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
            child: Text('Quick Settings'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          Text('Quick Settings'),
          Divider(
            color: Colors.black,
            thickness: 2,
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: '1W Max Power',
                hintText: '280'
            ),
            keyboardType: TextInputType.number,
            controller: _maxPower1WDunkController,
            onChanged: (String value) {
              appData.maxPower1WDunk = double.parse(value);
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
                labelText: '1W Tomahawk Max Power',
                hintText: '290'
            ),
            keyboardType: TextInputType.number,
            controller: _maxPower1WTomahawkController,
            onChanged: (String value) {
              appData.maxPower1WTomahawk = double.parse(value);
            },
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