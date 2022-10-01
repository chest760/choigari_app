import 'dart:io';

import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:uuid/uuid.dart';

class ChoigariNetwork {
  static Future<String> getWifiBSSID() async {
    if (kIsWeb) {
      return "fake-bssid";
    }
    var _networkInfo = NetworkInfo();
    if (Platform.isIOS) {
      LocationAuthorizationStatus status = await _networkInfo.getLocationServiceAuthorization();
      if (status == LocationAuthorizationStatus.notDetermined) {
        status = await _networkInfo.requestLocationServiceAuthorization();
      }
    }
    var wifiBSSID = await _networkInfo.getWifiBSSID();
    if (wifiBSSID == null) {
      print("bssid is null");
      return const Uuid().v1();
    }
    return wifiBSSID;
  }
}
