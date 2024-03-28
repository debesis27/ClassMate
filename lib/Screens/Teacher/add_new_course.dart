import 'package:flutter/material.dart';
import 'package:ClassMate/Models/course_info_model.dart';

class AddNewCourse extends StatefulWidget {
  const AddNewCourse({super.key});

  @override
  _AddNewCourse createState() => _AddNewCourse();
}

class _AddNewCourse extends State<AddNewCourse> {
  String courseCode = '';
  String courseTitle = '';
  String academicYear = '';

  void saveInputs() {
    // Save the inputs from the text fields
    // You can use the values of courseCode, courseTitle, and academicYear here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Course'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Course Code',
              ),
              onChanged: (value) {
                setState(() {
                  courseCode = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Course Title',
              ),
              onChanged: (value) {
                setState(() {
                  courseTitle = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Academic Year',
              ),
              onChanged: (value) {
                setState(() {
                  academicYear = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: saveInputs,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
