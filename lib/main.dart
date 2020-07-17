import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:pangya_calculator/Screens/calculator1WDunk.dart';
import 'package:pangya_calculator/Screens/calculator6i.dart';
import 'package:pangya_calculator/Screens/calculator1WToma.dart';
import 'package:pangya_calculator/drawer.dart';

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
      home: tabBar(),
    );
  }
}

class tabBar extends StatelessWidget {
  final List<Tab> myTabs = <Tab>[
    Tab(text: '1W Dunk'),
    Tab(text: '1W Toma'),
    Tab(text: '6i Beam'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pangya Calculator"),
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        drawer: drawerWidget(),
        body: TabBarView(
          children: [
            Calculator1WDunkForm(),
            Calculator1WTomaForm(),
            Calculator6iForm(),
          ]
        ),
      ),
    );
  }
}