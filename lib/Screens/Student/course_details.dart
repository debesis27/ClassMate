import 'package:flutter/material.dart';
import '../../Models/course_info_model.dart';
import '../../bluetooth/ble_scan.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.name),
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
              child: Text('Stats for ${course.name}'),
            ),
          ],
        ),
      ),
    );
  }
}