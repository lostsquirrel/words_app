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
  final url = Uri.parse("$baseUrl$path");

  final resp = await http.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    },
    body: json.encode(
      params,
    ),
  );
  if (resp.statusCode != 200) {
    throw HttpException(resp.body);
  }
  return resp.body;
}

Future<dynamic> sendGet(String path) async {
  final url = Uri.parse("$baseUrl$path");
  // print("get $path");
  final resp = await http.get(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer $token"
    },
  );
  if (resp.statusCode != 200) {
    throw HttpException(resp.body);
  }

  return resp.body;
}
