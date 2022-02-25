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

