import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:ClassMate/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentCourseDetailScreen extends StatelessWidget {
  final Course course;
  final Database database;

  const StudentCourseDetailScreen(
      {super.key, required this.course, required this.database});

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
            actions: [
              CourseSettings(course: course, database: database),
            ]),
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

class CourseSettings extends StatelessWidget {
  final Course course;
  final Database database;

  const CourseSettings(
      {super.key, required this.course, required this.database});

  @override
  Widget build(BuildContext context) {
    Future<dynamic> showCourseId(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text(
                  'Course Id',
                  style: TextStyle(fontSize: 26),
                ),
                content: Row(
                  children: [
                    Text(
                      course.courseReferenceId,
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: course.courseReferenceId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                ]);
          });
    }

    Future<dynamic> leaveCourse(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Leave Class'),
                content: const Text(
                    'Are you sure you want to unenroll from this course'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      database.studentLeaveCourse(course.courseReferenceId);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Leave'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  )
                ]);
          });
    }

    return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'show-course-id') {
            showCourseId(context);
          } else if (value == 'leave-class') {
            leaveCourse(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Option'),
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'show-course-id',
                child: Text('Show Course Id'),
              ),
              const PopupMenuItem<String>(
                value: 'leave-class',
                child: Text('Leave Class'),
              ),
            ]);
  }
}
