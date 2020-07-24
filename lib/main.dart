import 'package:flutter/material.dart';
import 'package:pangya_calculator/Screens/settingsPage.dart';
import 'package:pangya_calculator/blocs/calculatorBloc.dart';
import 'package:pangya_calculator/drawer.dart';
import 'package:pangya_calculator/Screens/calculatorWidget.dart';
import 'package:pangya_calculator/blocs/calculatorProvider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangya Calculator',
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