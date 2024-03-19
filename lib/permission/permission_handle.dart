// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
//
// class PermissionsService {
//   final PermissionHandler permissionHandler = PermissionHandler();
//
//   Future<bool> requestPermission() async {
//     List<PermissionGroup> permission = [
//       PermissionGroup.locationWhenInUse,
//       PermissionGroup.bluetoothScan
//     ];
//     var result = await permissionHandler.requestPermissions(permission);
//     if (result[permission] == PermissionStatus.granted) {
//       return true;
//     }
//     return false;
//   }
// }
