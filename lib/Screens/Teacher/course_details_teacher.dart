import 'package:ClassMate/Models/course_info_model.dart';
import 'package:flutter/material.dart';

class Student {
  final String name;
  final String entryNumber;
  bool isPresent;
  int totalAttendance = 0;

  void markPresent() {
    isPresent = true;
  }

  void markAbsent() {
    isPresent = false;
  }

  Student(
      {required this.name, required this.entryNumber, this.isPresent = false, this.totalAttendance = 0}
    );
}

class TeacherCourseDetailScreen extends StatefulWidget {
  final Course course;
  bool attendanceTaken = false; //TODO: Add function to get attendance status

  TeacherCourseDetailScreen({super.key, required this.course});

  @override
  State<TeacherCourseDetailScreen> createState() =>
      _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen> {
  void setAttendanceTaken() {
    //TODO: Add function to set attendance status
    setState(() {
      widget.attendanceTaken = true;
    });
  }

  List<Student> students = [
    Student(name: 'John Doe', entryNumber: '2021MCB1245', isPresent: true, totalAttendance: 5),
    Student(name: 'Jane Smith', entryNumber: '2021MCB1246', totalAttendance: 8),
    Student(name: 'Alice Johnson', entryNumber: '2021MCB1247', totalAttendance: 1),
    Student(name: 'Bob Williams', entryNumber: '2021MCB1248', isPresent: true, totalAttendance: 10),
    Student(name: 'Emily Brown', entryNumber: '2021MCB1249', isPresent: true, totalAttendance: 7),
    Student(name: 'Michael Davis', entryNumber: '2021MCB1250', totalAttendance: 3),
    Student(name: 'Olivia Miller', entryNumber: '2021MCB1251', totalAttendance: 6),
    Student(name: 'William Wilson', entryNumber: '2021MCB1252', isPresent: true),
    Student(name: 'Sophia Taylor', entryNumber: '2021MCB1253', totalAttendance: 2),
    Student(name: 'James Anderson', entryNumber: '2021MCB1254', isPresent: true, totalAttendance: 9),
    Student(name: 'James Nanderson', entryNumber: '2021MCB1255', totalAttendance: 4),
    Student(name: 'Tom Hardy', entryNumber: '2021MCB1256', isPresent: true, totalAttendance: 11),
    Student(name: 'Tommy Hardy', entryNumber: '2021MCB1257', totalAttendance: 12),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.course.courseCode),
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
            Center(
              child: widget.attendanceTaken
                  ? AttendanceResultOfToday(allStudents: students)
                  : TakeAttendance(onPressed: setAttendanceTaken),
            ),
            Center(
              child: AttendanceStats(allStudents: students),
            ),
          ],
        ),
      ),
    );
  }
}

class TakeAttendance extends StatelessWidget {
  final Function onPressed;

  const TakeAttendance({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            //TODO: Add function to take attendance
            onPressed();
          },
          child: const Text('Take Attendance'),
        ));
  }
}

class AttendanceResultOfToday extends StatefulWidget {
  final List<Student> allStudents;

  const AttendanceResultOfToday({super.key, required this.allStudents});

  String findTodaysTotalAttendance() {
    int count = 0;
    for (var student in allStudents) {
      if (student.isPresent) {
        count++;
      }
    }
    return "$count/${allStudents.length}";
  }

  @override
  State<AttendanceResultOfToday> createState() =>
      _AttendanceResultOfTodayState();
}

class _AttendanceResultOfTodayState extends State<AttendanceResultOfToday> {
  @override
  Widget build(BuildContext context) {
    String todaysTotalAttendance = widget.findTodaysTotalAttendance();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              "Today's Attendance: $todaysTotalAttendance"),
          Expanded(
            child: ListView.builder(
              itemCount: widget.allStudents.length,
              itemBuilder: (context, index) {
                final student = widget.allStudents[index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text(student.entryNumber),
                  leading: student.isPresent
                      ? const Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'mark_present') {
                        // TODO: Implement the logic to mark the student as present
                        setState(() {
                          student.markPresent();
                        });
                      } else {
                        // TODO: Implement the logic to mark the student as absent
                        setState(() {
                          student.markAbsent();
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'mark_present',
                        child: Text('Mark Present'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'mark_absent',
                        child: Text('Mark Absent'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceStats extends StatelessWidget {
  final List<Student> allStudents;

  const AttendanceStats({super.key, required this.allStudents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: allStudents.length,
        itemBuilder: (context, index) {
          Student student = allStudents[index];
          return Card(
            child: ExpansionTile(
              title: Text('${student.name} (${student.entryNumber})'),
              children: <Widget>[
                ListTile(
                  title: Text('Total Attendance: ${student.totalAttendance}'),
                ),
              ],
            ),
          );
        });
  }
}
