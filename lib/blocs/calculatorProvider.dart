//import 'package:flutter/material.dart';
//import 'package:pangya_calculator/blocs/calculatorBloc.dart';
//
//class CalculatorProvider extends InheritedWidget {
//  final bloc = CalculatorBloc();
//
//  CalculatorProvider({Key key, Widget child}) : super(key: key, child: child);
//
//  bool updateShouldNotify(_) => true;
//
//  static CalculatorBloc of(BuildContext context) {
//    //* What it does is through the "of" function, it looks through the context of a widget from the deepest in the widget tree
//    //* and it keeps travelling up to each widget's parent's context until it finds a "Provider" widget
//    //* and performs the type conversion to Provider through "as Provider" and then access the Provider's bloc instance variable
//    return (context.dependOnInheritedWidgetOfExactType() as CalculatorProvider).bloc;
//  }
//}