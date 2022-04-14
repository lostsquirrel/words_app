import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../domains/http_exception.dart';
import '../config.dart';
import '../utils.dart';

class User with ChangeNotifier {
  String? _token;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    return _token;
  }

  Future<bool> bind(inviceCode) async {
    var device = await getDeviceInfo();
    if (device == null) {
      throw Exception("cannot get deivceId");
    }
    final url = Uri.http(baseUrl, "/user/join");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {
          "device_type": device.deviceType,
          "device_id": device.deviceId,
          "invite_code": inviceCode
        },
      ),
    );
    if (resp.statusCode != 200) {
      var error = json.decode(resp.body)['message'];
      throw HttpException(error);
    }
    final responseData = json.decode(resp.body);
    if (responseData['error'] != null) {
      throw Exception(responseData['error']['message']);
    }

    return true;
  }

  Future<bool> tryAutoLogin() async {
    var device = await getDeviceInfo();
    if (device == null) {
      throw Exception("cannot get deivceId");
    }
    final url = Uri.http(baseUrl, "/user/login");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {"device_type": device.deviceType, "device_id": device.deviceId},
      ),
    );
    final responseData = json.decode(resp.body);
    if (responseData['error'] != null) {
      throw Exception(responseData['error']['message']);
    }
    _token = responseData['token'];
    // notifyListeners();
    return true;
  }
}
