import 'package:flutter/material.dart';
import 'package:pangya_calculator/Screens/settingsPage.dart';
import 'package:pangya_calculator/blocs/calculatorBloc.dart';
import 'package:pangya_calculator/Screens/calculatorWidget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pangya_calculator/appConfig.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesProvider();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangya Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => CalculatorBloc(),
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Pangya Calculator"),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    }
                )
              ],
            ),
            body: SingleChildScrollView (
              child: Center(
              child: CalculatorWidget(),
            )
          )
        )
    );
  }
}

class SharedPreferencesProvider {
  static Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  static SharedPreferences _prefsInstance;

  SharedPreferencesProvider() {
    init();
  }

  static void init() async {
    _prefsInstance = await prefs;
    appData.maxPower1WDunk =
    (_prefsInstance.getDouble('maxPower1WDunk') ?? appData.maxPower1WDunk);
    appData.spin = (_prefsInstance.getDouble('spin') ?? appData.spin);
    appData.maxPower1WTomahawk =
    (_prefsInstance.getDouble('MaxPower1WPowershot') ?? appData.maxPower1WTomahawk);
    appData.maxPower2WTomahawk = appData.maxPower1WTomahawk - 20;
    appData.maxPower3WTomahawk = appData.maxPower1WTomahawk - 40;
  }
}