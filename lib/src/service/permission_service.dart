/*
 * Project Name:  [maepyoso] -  V1.2.0+
 * File: /Users/bakbeom/work/test/getxtest/lib/src/service/permission_service.dart
 * Created Date: 2022-06-24 14:56:06
 * Last Modified: 2022-06-24 14:59:01
 * Author: bakbeom
 * Modified By: bakbeom
 * copyright @ 2022  케이씨엘디 주식회사 ALL RIGHTS RESERVED. 
 * ---	---	---	---	---	---	---	---	---	---	---	---	---	---	---	---
 * 												Discription													
 * ---	---	---	---	---	---	---	---	---	---	---	---	---	---	---	---
 */

import 'package:permission_handler/permission_handler.dart';

class PermissonService {
  factory PermissonService() => _sharedInstance();
  static PermissonService? _instance;
  PermissonService._() {
    //
  }
  static PermissonService _sharedInstance() {
    _instance ??= PermissonService._();
    return _instance!;
  }

  static var getCameraAndPhotoLibrayPermisson = [
    Permission.camera,
    Permission.mediaLibrary
  ];
  static var getLocationPermisson = [
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse
  ];
  static var blueToothPermisson = [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect
  ];
  // 위치 권한 상태 체크 및 요청.
  static Future<bool?> checkLocationPermisson() async {
    List<bool> canUse = [];
    await Future.forEach(getLocationPermisson, (permission) async {
      permission as Permission;
      // 3가지 권한(한번만,항상,사용시)을 모두 체크한다.
      if (await permission.isGranted) {
        canUse.add(true);
      } else {
        canUse.add(false);
      }
    }).whenComplete(() async {
      // 체크결과에 허용되는 권한이 없으면
      if (!canUse.contains(true)) {
        // 권한요청후 결과를 canUse에 넣어준다.
        await requestPermission(Permission.location)
            .then((isGranted) => canUse.add(isGranted));
      }
    });
    // 권한이 1개라도 허용 되면 true.
    return canUse.contains(true);
  }

  // 포토 & 라이브러리 권한 부여상태 체크 및 요청.
  static Future<bool?> checkPhotoAndLibrayPermisson() async {
    List<bool> canUse = [];
    await Future.forEach(getCameraAndPhotoLibrayPermisson, (permission) async {
      permission as Permission;
      // 권한 필요시 요청.
      if (await permission.isGranted) {
        canUse.add(true);
      } else {
        await requestPermission(permission).then((value) => canUse.add(true));
      }
    });

    return canUse.contains(false) ? false : true;
  } // 포토 & 라이브러리 권한 부여상태 체크 및 요청.

  static Future<bool?> checkdBlueToothPermisson() async {
    List<bool> canUse = [];
    await Future.forEach(blueToothPermisson, (permission) async {
      permission as Permission;
      // 권한 필요시 요청.
      if (await permission.isGranted) {
        canUse.add(true);
      } else {
        await requestPermission(permission).then((value) => canUse.add(true));
      }
    });

    return canUse.contains(false) ? false : true;
  }

  // 권한 요청.
  static Future<bool> requestPermission(Permission permission) async {
    return await permission.request().isGranted;
  }

  //  권한 상태 체크.
  static Future<bool> checkPermissionStatus(Permission permission) async {
    return await permission.status.isGranted;
  }
}
