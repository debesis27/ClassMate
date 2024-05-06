import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChoisePage extends StatefulWidget {
  final User user;
  final FirebaseAuth auth;
  final Database database;
  const ChoisePage({super.key, required this.user, required this.auth, required this.database});
  @override
  State<ChoisePage> createState() => _ChoisePageState();
}

class _ChoisePageState extends State<ChoisePage> {
  bool isTeacher = false;
  bool isStudent = false;

  @override
  Widget build(BuildContext context) {
    if (isTeacher) {
      return TeacherHomePage(auth: widget.auth, user: widget.user);
    }
    if (isStudent) {
      return StudentHomePage(auth: widget.auth, user: widget.user);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Role'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select Your Role',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 30),
            ChoiceButton(
              label: 'Teacher',
              onPressed: () {
                // Navigate to Teacher Page or perform other actions
                widget.database.setTeachersCollection();
                setState(() {
                  isTeacher = true;
                });
              },
            ),
            SizedBox(height: 20),
            ChoiceButton(
              label: 'Student',
              onPressed: () {
                // Navigate to Student Page or perform other actions
                widget.database.setStudentsCollection();
                setState(() {
                  isStudent = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}



class ChoiceButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ChoiceButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Button color
        foregroundColor: Colors.white, // Text color
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}