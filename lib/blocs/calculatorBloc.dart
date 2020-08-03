import 'package:flutter/cupertino.dart';
import 'package:pangya_calculator/appConfig.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:pangya_calculator/models/calculatorModels.dart';
import 'package:pangya_calculator/Screens/calculator1WDunk.dart';
import 'package:pangya_calculator/Screens/calculator1WToma.dart';
import 'package:pangya_calculator/Screens/calculator2WToma.dart';
import 'package:pangya_calculator/Screens/calculator3WToma.dart';
import 'package:pangya_calculator/Screens/calculator6i.dart';
import 'package:pangya_calculator/Screens/parseYAML.dart';

enum EventType {
  updatePinDistance,
  updateElevation,
  updateWindSpeed,
  updateWindAngle,
  updateWindDirection,
  updateBreaks,
  updateGreenSlope,
  updateTerrain,
  updateCalculator,
  updatePinDescription,
}

class CalculatorState {
  const CalculatorState({
    @required this.pinDistance,
    @required this.elevation,
    @required this.windSpeed,
    @required this.windAngle,
    @required this.windDirection,
    @required this.breaks,
    @required this.greenSlope,
    @required this.terrain,
  });

  final String pinDistance;
  final String elevation;
  final String windSpeed;
  final String windAngle;
  final bool windDirection;
  final String breaks;
  final String greenSlope;
  final String terrain;

  const CalculatorState.initial()
      : this(
        pinDistance: "230",
        elevation: "0",
        windSpeed: "1",
        windAngle: "45",
        windDirection: true,
        breaks: "0",
        greenSlope: "0",
        terrain: "100",
      );
}

class CalculatorInitial extends CalculatorState {}

class CalculatorEvent {
  final EventType eventType;
  final String value;

  CalculatorEvent(this.eventType, this.value);
}

class CalculatorSuccess extends CalculatorState {
  final Results result;

  CalculatorSuccess(this.result);
}

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {

  var _results = Results();
  var _inputs = InputData();
  List<bool> _isSelected = [true, false];
  List<double> pinOutput;

  CalculatorBloc() : super(CalculatorState.initial());

  var _pinDistanceSubject = new BehaviorSubject<String>.seeded("230");
  Stream<String> get pinDistance => _pinDistanceSubject.stream;

  var _elevationSubject = new BehaviorSubject<String>.seeded("0");
  Stream<String> get elevation => _elevationSubject.stream;

  var _resultsSubject = new BehaviorSubject<Results>();
  Stream<Results> get results => _resultsSubject.stream;

  var _isSelectedSubject = new BehaviorSubject<List>();
  Stream<List> get isSelected => _isSelectedSubject.stream;

  var _calculationSelectedSubject = new BehaviorSubject<String>();
  Stream<String> get calculationSelected => _calculationSelectedSubject.stream;

  var _pinInformationSubject = new BehaviorSubject<String>();
  Stream<String> get pinInformation => _pinInformationSubject.stream;

  var _maxPowerSubject = new BehaviorSubject<String>();
  Stream<String> get maxPower => _maxPowerSubject.stream;

  Function calculate = Calculator1WDunk().calculate1WDunk;

  @override
  Stream<CalculatorState> mapEventToState(CalculatorEvent event) async* {
    switch (event.eventType){
      case EventType.updateCalculator:
        _calculationSelectedSubject.value = event.value;
        if (event.value == "1W Dunk"){
          calculate = Calculator1WDunk().calculate1WDunk;
          _results = calculate(_inputs, _results);
          _maxPowerSubject.value = appData.maxPower1WDunk.toString();
          yield CalculatorSuccess(_results);
        } else if (event.value == "1W Tomahawk"){
          calculate = Calculator1WTomahawk().calculate1WToma;
          _results = calculate(_inputs, _results);
          _maxPowerSubject.value = appData.maxPower1WTomahawk.toString();
          yield CalculatorSuccess(_results);
        } else if (event.value == "2W Tomahawk"){
          calculate = Calculator2WTomahawk().calculate2WToma;
          _results = calculate(_inputs, _results);
          _maxPowerSubject.value = appData.maxPower2WTomahawk.toString();
          yield CalculatorSuccess(_results);
        } else if (event.value == "3W Tomahawk"){
          calculate = Calculator3WTomahawk().calculate3WToma;
          _results = calculate(_inputs, _results);
          _maxPowerSubject.value = appData.maxPower3WTomahawk.toString();
          yield CalculatorSuccess(_results);
        } else if (event.value == "6i Beam"){
          calculate = Calculator6i().calculateDunk6i;
          _results = calculate(_inputs, _results);
          _maxPowerSubject.value = appData.maxPower1WTomahawk.toString();
          yield CalculatorSuccess(_results);
        }
        break;
      case EventType.updatePinDistance:
        _inputs.pinDistance = double.parse(event.value);
        _pinDistanceSubject.value = event.value;
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateElevation:
        _inputs.elevation = double.parse(event.value);
        _elevationSubject.value = event.value;
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateWindSpeed:
        _inputs.windSpeed = double.parse(event.value);
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateWindAngle:
        _inputs.windAngle = double.parse(event.value);
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateWindDirection:
        _inputs.windDirection = event.value == "0";
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
          if (buttonIndex == num.parse(event.value)) {
            _isSelected[buttonIndex] = true;
          } else {
            _isSelected[buttonIndex] = false;
          }
        }
        _isSelectedSubject.value = _isSelected;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateBreaks:
        _inputs.breaks = double.parse(event.value);
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateGreenSlope:
        _inputs.greenSlope = double.parse(event.value);
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updateTerrain:
        _inputs.terrain = event.value;
        _results = calculate(_inputs, _results);
        _resultsSubject.value = _results;
        appData.terrain = event.value;
        yield CalculatorSuccess(_results);
        break;
      case EventType.updatePinDescription:
        pinOutput = await ParseYAML().obtainPinInformation(event.value);
        _pinInformationSubject.value = event.value;
        _inputs.pinDistance = pinOutput[0];
        _pinDistanceSubject.value = pinOutput[0].toString();
        _inputs.elevation = pinOutput[1];
        _elevationSubject.value = pinOutput[1].toString();
        _results = calculate(_inputs, _results);
        yield CalculatorSuccess(_results);
        break;
    }
  }

  void dispose(){
    _pinDistanceSubject.close();
    _elevationSubject.close();
    _resultsSubject.close();
    _isSelectedSubject.close();
    _calculationSelectedSubject.close();
    _maxPowerSubject.close();
    _pinInformationSubject.close();
  }
}