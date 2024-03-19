import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:convert';

class Ble_Body extends StatelessWidget {
  const Ble_Body({super.key});
  // bool scanon = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Available Bluetooth devices: '),
        Expanded(
          child: BleScan(),
        ),
      ],
    );
  }
}

class BleScan extends StatefulWidget {
  const BleScan({super.key});

  @override
  State<BleScan> createState() => _BleScanState();
}

class _BleScanState extends State<BleScan> {
  List<ScanResult> _scanresults = [];

  @override
  void initState() {
    print("Scan Called");
    super.initState();
    _scanresults = [];
    FlutterBluePlus.startScan();
    _startDiscovery();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _startDiscovery() {
    print("Discovery started");

    FlutterBluePlus.scanResults.listen((devices) {
      for (ScanResult _device in devices) {
        print(
            'Found Bluetooth device: ${_device.device.platformName} (${_device.device.remoteId})');
        if (mounted) {
          setState(() {
            final exisiting_index = _scanresults.indexWhere((element) =>
                element.device.remoteId == _device.device.remoteId);
            if (exisiting_index >= 0) {
              _scanresults[exisiting_index] = _device;
            } else {
              _scanresults.add(_device);
            }
          });
        } else {
          dispose();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _scanresults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_scanresults[index].device.platformName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_scanresults[index].device.remoteId.toString()),
              Text(_scanresults[index]
                  .advertisementData
                  .serviceData
                  .entries
                  .map((entry) =>
                      "Service UUID: ${entry.key}, Data: ${entry.value}")
                  .join("\n")),
            ],
          ),
        );
      },
    );
  }
}
