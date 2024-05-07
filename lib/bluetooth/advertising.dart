import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

Future<void> startAdvertising({required String id}) async {

  const platform = MethodChannel('com.example.ClassMate/advertise');

  try {
    var status = await Permission.bluetoothAdvertise.status;
    if (!status.isGranted) {
      status = await Permission.bluetoothAdvertise.request();
    }
    if (status.isGranted) {
      await platform.invokeMethod('startAdvertising', <String, dynamic>{'id': id});
    } else {
      print("Bluetooth advertising permission not granted");
    }
  } on PlatformException catch (e) {
    print("Failed to start advertising: '${e.message}'.");
  }
}


Future<void> stopAdvertising() async {
  const platform = MethodChannel('com.example.ClassMate/advertise');
  try {
    await platform.invokeMethod('stopAdvertising');
  } on PlatformException catch (e) {
    print("Failed to stop advertising: '${e.message}'.");
  }
}
