import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class DeviceInfo {
  final int deviceType;
  final String deviceId;
  DeviceInfo(this.deviceType, this.deviceId);
}

Future<DeviceInfo?> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var deviceId = androidInfo.androidId;
    return DeviceInfo(0, deviceId!);
  }

  return null;
}

Future<dynamic> sendPost(String path, Map<String, Object> params) async {
  final url = Uri.https(baseUrl, path);

  final resp = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + token
    },
    body: json.encode(
      params,
    ),
  );
  if (resp.statusCode != 200) {
    if (resp.statusCode == 500) {
      throw HttpException(resp.body);
    }
    var error = json.decode(resp.body)['message'];
    throw HttpException(error);
  }
  final responseData = json.decode(resp.body);
  if (responseData is Map && responseData['error'] != null) {
    throw Exception(responseData['error']['message']);
  }
  return responseData;
}

Future<dynamic> sendGet(String path) async {
  final url = Uri.https(baseUrl, path);
  // print("get $path");
  final resp = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + token
    },
  );
  if (resp.statusCode != 200) {
    if (resp.statusCode == 500) {
      throw HttpException(resp.body);
    }
    var error = json.decode(resp.body)['message'];
    throw HttpException(error);
  }
  final responseData = json.decode(resp.body);
  if (responseData is Map && responseData['error'] != null) {
    throw Exception(responseData['error']['message']);
  }
  return responseData;
}
