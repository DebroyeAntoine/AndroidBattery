import 'dart:async';


import 'package:battery_plus/battery_plus.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:workmanager/workmanager.dart';

import 'data/Repository/battery_repo.dart';
import 'data/data_provider/battery_provider.dart';
import 'package:http/http.dart' as http;

part 'test_state.dart';

const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        var battery = Battery();
        var batlevel = await battery.batteryLevel;
        final urlFinal = inputData!["string"] + batlevel.toString();
        await repo.getBattery(urlFinal);
        break;
    }
    return Future.value(true);
  });
}

final BatteryRepository repo = BatteryRepository(api: ServerAPI(http.Client()));

class TestCubit extends Cubit<TestState> {

  TestCubit() : super(TestState("", Colors.grey));

  urlChanged(String url) {
    state.path = url;
  }

  validate() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    state.status = Colors.blue;
    emit(state);
    try {
      Workmanager().registerPeriodicTask("1", fetchBackground, inputData: {
        'string': state.path,
      });

      Workmanager().registerPeriodicTask("2", fetchBackground,
          initialDelay: const Duration(minutes: 5),
          inputData: {
            'string': state.path,
          });
      Workmanager().registerPeriodicTask("3", fetchBackground,
          initialDelay: const Duration(minutes: 10),
          inputData: {
            'string': state.path,
          });
    } catch (e) {
      state.status = Colors.red;
      emit(state);
    }
    state.status = Colors.green;
    emit(state);
  }

  cancel() async {
    await Workmanager().cancelAll();
  }
}
