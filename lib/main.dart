import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
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
  startAdvertising();
  // PermissionsService().requestPermission();
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
      home: const StudentHomePage(),
    );
  }
}
