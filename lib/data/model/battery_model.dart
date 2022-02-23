import 'dart:convert';

import 'package:http/http.dart';

class Battery2{
  final int status;

  const Battery2({required this.status,});

  static dynamic fromJson(Response json){
    final parsed = jsonDecode(json.body);
    return parsed["status"];
  }

}