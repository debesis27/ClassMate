import 'package:ClassMate/Marks/CSV.dart';
import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Models/session_info.dart';
import 'package:ClassMate/services/database.dart';
import 'package:ClassMate/services/get_sessions.dart';
import 'package:ClassMate/services/mark_attendence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
      {required this.name,
      required this.entryNumber,
      this.isPresent = false,
      this.totalAttendance = 0});
}

class TeacherCourseDetailScreen extends StatefulWidget {
  final Course course;
  final Database database;
  final Function onUpdate;

  const TeacherCourseDetailScreen(
      {super.key, required this.course, required this.database, required this.onUpdate});

  @override
  State<TeacherCourseDetailScreen> createState() =>
      _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen> {
  bool attendanceTaken = false; //TODO: Add function to get attendance status
  String sessionId = "";

  void setAttendanceTaken() {
    //TODO: Add function to set attendance status
    // setState(() {
    //   attendanceTaken = true;
    // });
  }

  void setCurrentSessionId(String id) {
    setState(() {
      sessionId = id;
    });
  }

  List<Student> students = [
    Student(
        name: 'John Doe',
        entryNumber: '2021MCB1245',
        isPresent: true,
        totalAttendance: 5),
    Student(name: 'Jane Smith', entryNumber: '2021MCB1246', totalAttendance: 8),
    Student(
        name: 'Alice Johnson', entryNumber: '2021MCB1247', totalAttendance: 1),
    Student(
        name: 'Bob Williams',
        entryNumber: '2021MCB1248',
        isPresent: true,
        totalAttendance: 10),
    Student(
        name: 'Emily Brown',
        entryNumber: '2021MCB1249',
        isPresent: true,
        totalAttendance: 7),
    Student(
        name: 'Michael Davis', entryNumber: '2021MCB1250', totalAttendance: 3),
    Student(
        name: 'Olivia Miller', entryNumber: '2021MCB1251', totalAttendance: 6),
    Student(
        name: 'William Wilson', entryNumber: '2021MCB1252', isPresent: true),
    Student(
        name: 'Sophia Taylor', entryNumber: '2021MCB1253', totalAttendance: 2),
    Student(
        name: 'James Anderson',
        entryNumber: '2021MCB1254',
        isPresent: true,
        totalAttendance: 9),
    Student(
        name: 'James Nanderson',
        entryNumber: '2021MCB1255',
        totalAttendance: 4),
    Student(
        name: 'Tom Hardy',
        entryNumber: '2021MCB1256',
        isPresent: true,
        totalAttendance: 11),
    Student(
        name: 'Tommy Hardy', entryNumber: '2021MCB1257', totalAttendance: 12),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.course.courseCode),
            backgroundColor: Colors.blue,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Attendance'),
                Tab(text: 'Students'),
                Tab(text: 'Marks Upload (CSV)'),
              ],
            ),
            actions: [
              CourseSettings(course: widget.course, database: widget.database, onUpdate: widget.onUpdate)
            ]),
        body: TabBarView(
          children: [
            Center(
              child: SessionManager(courseId: widget.course.courseReferenceId),
            ),
            Center(
              child: AttendanceStats(allStudents: students),
            ),
            Center(
              child: CSVUploaderWidget(courseId: widget.course.courseReferenceId),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionManager extends StatefulWidget {
  final String courseId;
  const SessionManager({super.key, required this.courseId});

  @override
  State<SessionManager> createState() => _SessionManagerState();
}


class _SessionManagerState extends State<SessionManager> {
  List<Session> sessions = [];
  bool isLoading = true;

  Future<void> fetchSessions() async {
    var sessions = await getSessions(widget.courseId);  // Assume this now returns List<Session>
    setState(() {
      this.sessions = sessions;
      isLoading = false;
    });
  }

  Future<void> createSession() async {
    setState(() {
      isLoading = true;
    });
    await markAttendance(widget.courseId).then((value) {
      fetchSessions();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              createSession();
            },
            child: const Text('Add New Session and Take Attendance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ListTile(
                      title: Text('Session ${index + 1} - ${DateFormat('yyyy-MM-dd HH:mm').format(session.datetime)}'),
                      onTap: () {
                        // Implement your onTap functionality here
                        // widget.setCurrentSessionId(session.id);
                      },
                    );
                  },
                ),
        ),
      ],
    );
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total Attendance: $todaysTotalAttendance",
              style: const TextStyle(fontSize: 16),
            ),
          ),
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

class CourseSettings extends StatefulWidget {
  final Course course;
  final Database database;
  final Function onUpdate;

  const CourseSettings(
      {super.key, required this.course, required this.database, required this.onUpdate});

  @override
  State<CourseSettings> createState() => _CourseSettingsState();
}

class _CourseSettingsState extends State<CourseSettings> {
  @override
  Widget build(BuildContext context) {
    String studentId = "";

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
                      widget.course.courseReferenceId,
                      style: const TextStyle(fontSize: 15),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: widget.course.courseReferenceId));
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

    Future<dynamic> addStudent(BuildContext context, String studentId) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Add Student'),
                content: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Lowercase Entry no. '
                  ),
                  onChanged: (value) {
                  setState(() {
                    studentId = value;
                  });
                }),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await widget.database.addStudentToCourse(studentId, widget.course.courseReferenceId);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
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

    Future<dynamic> removeStudent(BuildContext context, String studentId) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Remove Student'),
                content: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Lowercase Entry no. '
                  ),
                  onChanged: (value) {
                  setState(() {
                    studentId = value;
                  });
                }),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await widget.database.removeStudentFromCourse(studentId, widget.course.courseReferenceId);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Remove'),
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

    Future<dynamic> deleteCourse(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Delete Course'),
                content:
                    const Text('Are you sure you want to delete this course'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await widget.database.deleteCourse(widget.course.courseReferenceId);
                      Navigator.of(context).pop();
                      Navigator.pop(context, true);
                      await widget.onUpdate();
                    },
                    child: const Text('Delete'),
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
      onSelected: (value) => {
        if (value == 'show-course-id')
          {showCourseId(context)}
        else if (value == 'add-student')
          {addStudent(context, studentId)}
        else if (value == 'remove-student')
          {removeStudent(context, studentId)}
        else if (value == 'delete-course')
          {deleteCourse(context)}
        else
          {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Option'),
              ),
            )
          }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'show-course-id',
          child: Text('Show Course Id'),
        ),
        const PopupMenuItem<String>(
          value: 'add-student',
          child: Text('Add Student'),
        ),
        const PopupMenuItem<String>(
          value: 'remove-student',
          child: Text('Remove Student'),
        ),
        const PopupMenuItem<String>(
          value: 'delete-course',
          child: Text('Delete Course'),
        ),
      ],
    );
  }
}



class CSVUploaderWidget extends StatefulWidget {
  final String courseId;

  const CSVUploaderWidget({Key? key, required this.courseId}) : super(key: key);

  @override
  _CSVUploaderWidgetState createState() => _CSVUploaderWidgetState();
}

class _CSVUploaderWidgetState extends State<CSVUploaderWidget> {
  String _statusMessage = 'Ready to upload CSV';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ElevatedButton(
          onPressed: _pickAndUploadCSV,
          child: Text('Pick and Upload CSV'),
        ),
        SizedBox(height: 20),
        Text(_statusMessage),
      ],
    );
  }

  void _pickAndUploadCSV() async {
    setState(() {
      _statusMessage = "Processing...";
    });

    CSV csv = CSV(courseId: widget.courseId);
    await csv.pickAndProcessCSV().then((_) {
      setState(() {
        _statusMessage = "Upload Successful!";
      });
    }).catchError((error) {
      setState(() {
        _statusMessage = "Failed to upload: $error";
      });
    });
  }
}