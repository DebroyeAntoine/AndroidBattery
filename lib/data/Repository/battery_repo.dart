import 'package:batt/data/data_provider/battery_provider.dart';
import 'package:batt/data/model/battery_model.dart';
import 'package:http/http.dart';


class BatteryRepository{
  final ServerAPI api;
  BatteryRepository({required this.api});

  Future<dynamic> getBattery(String url) async{
    final Response rawStatus = await api.getRawCode(url);

    final batt = Battery2.fromJson(rawStatus);
    return batt;
  }
}