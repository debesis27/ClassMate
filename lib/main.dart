// import 'package:ClassMate/Screens/Student/home_screen_student.dart';
// import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/Screens/sign_in_page.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ClassMate/bluetooth/advertising.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  String uid = "2021mcb1181";
  int timeout = 100;
  startAdvertising(id: uid);
  scanDevices(timeout: timeout);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInPage(),
    );
  }
}