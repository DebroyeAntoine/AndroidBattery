import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        final urlFinal = inputData!["string"].replaceAll(
            r"$battery", batlevel.toString());
        var sock = await Socket.connect("127.0.0.1", 8124,
            timeout: const Duration(seconds: 5));
        sock.write("loading");
        try {
          String result = await repo.getBattery(urlFinal);
          if (result == "OK") {
            sock.write("good");
          } else {
            sock.write("warning");
          }
          sock.close();
        } catch (e) {
          print(e);
          sock.write("error");
          sock.close();
          return Future.error("Can't establish connection");
        }
        break;
    }
    return Future.value(true);
  });
}

final BatteryRepository repo = BatteryRepository(api: ServerAPI(http.Client()));

class TestCubit extends Cubit<TestState> {

  var serverSocket;
  TestCubit() : super(TestState("", Colors.grey));

  urlChanged(String url) {
    state.path = url;
  }

  validate() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (state.path != "") {
      _prefs.setString('url', state.path);
    }
    else{
      state.path = _prefs.getString('url')!;
    }

    WidgetsFlutterBinding.ensureInitialized();
    await Workmanager().cancelAll();
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    Workmanager().registerPeriodicTask("1", fetchBackground,
        backoffPolicy: BackoffPolicy.exponential,
        inputData: {
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
    serverSocket = await ServerSocket.bind('127.0.0.1', 8124, shared: true);
    await serverSocket.listen(handleClient);
  }

  void handleClient(Socket client) {
    var clientSocket = client;

    clientSocket.listen((onData) {
      String status = String.fromCharCodes(onData).trim();
      switch (status) {
        case "loading":
          {
            emit(TestState("", Colors.blue));
            break;
          }
        case "good":
          {
            emit(TestState("", Colors.green));

            break;
          }
        case "warning":
          {
            emit(TestState("", Colors.orangeAccent));
            break;
          }
        case "error":
          {
            emit(TestState("", Colors.red));
            break;
          }
      }
    });
    return;
  }

  cancel() async {
    await serverSocket.close();
    await Workmanager().cancelAll();
    emit(TestState("", Colors.grey));
  }
}
