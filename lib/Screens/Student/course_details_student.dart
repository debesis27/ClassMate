import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:flutter/material.dart';

class StudentCourseDetailScreen extends StatelessWidget {
  final Course course;

  const StudentCourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.courseCode),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const Center(
              child: Ble_Body(),
            ),
            Center(
              child: Text('Stats for ${course.courseCode}'),
            ),
          ],
        ),
      ),
    );
  }
}
