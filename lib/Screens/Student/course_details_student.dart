import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:ClassMate/services/database.dart';
import 'package:flutter/material.dart';

class StudentCourseDetailScreen extends StatelessWidget {
  final Course course;
  final Database database;

  const StudentCourseDetailScreen({super.key, required this.course, required this.database});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.courseCode),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Stats'),
              Tab(text: 'Settings'),
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
            Center(
              child: CourseSettings(database: database, course: course,),
            )
          ],
        ),
      ),
    );
  }
}

class CourseSettings extends StatefulWidget {
  final Database database;
  final Course course;
  const CourseSettings({super.key, required this.database, required this.course});

  @override
  State<CourseSettings> createState() => _CourseSettingsState();
}

class _CourseSettingsState extends State<CourseSettings> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Course Id'),
                        content: Text(widget.course.courseReferenceId),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Ok'),
                          ),
                        ]
                      );
                    }
                  );
              },
              child: const Text('Show Course code'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Leave Class'),
                        content: const Text('Are you sure you want to unenroll from this course'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              widget.database.studentLeaveCourse(widget.course.courseReferenceId);
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
                        ]
                      );
                    }
                  );
              },
              child: const Text('Leave class'),
            ),
          ),
        )
      ],
    );
  }
}
