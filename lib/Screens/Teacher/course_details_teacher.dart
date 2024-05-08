import 'package:ClassMate/Marks/CSV.dart';
import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Models/session_info.dart';
import 'package:ClassMate/Models/student_model.dart';
import 'package:ClassMate/Screens/common_screen_widgets.dart';
import 'package:ClassMate/Screens/error_page.dart';
import 'package:ClassMate/services/database.dart';
import 'package:ClassMate/services/get_sessions.dart';
import 'package:ClassMate/services/mark_attendence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TeacherCourseDetailScreen extends StatefulWidget {
  final Course course;
  final Database database;
  final Function onUpdate;

  const TeacherCourseDetailScreen(
      {super.key,
      required this.course,
      required this.database,
      required this.onUpdate});

  @override
  State<TeacherCourseDetailScreen> createState() =>
      _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen> {
  String sessionId = "";

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
            title: Text(widget.course.courseCode,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4.0,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Attendance'),
                Tab(text: 'Students'),
                Tab(text: 'Marks'),
              ],
            ),
            actions: [
              CourseSettings(
                  course: widget.course,
                  database: widget.database,
                  onUpdate: widget.onUpdate)
            ]),
        body: TabBarView(
          children: [
            Center(
              child: sessionId != ""
                  ? AttendanceResultOfToday(
                      sessionId: sessionId,
                      courseId: widget.course.courseReferenceId,
                      database: widget.database)
                  : SessionManager(
                      courseId: widget.course.courseReferenceId,
                      setCurrentSessionId: setCurrentSessionId),
            ),
            Center(
              child: FutureBuilder(
              future: widget.database.getAllStudentsdata(widget.course.courseReferenceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return buildErrorWidget(context, snapshot.error, () {setState(() {});});
                }
                final students = snapshot.data as List<Student>;
                return AttendanceStats(allStudents: students);
              },
              ),
            ),
            Center(
              child:
                  CSVUploaderWidget(courseId: widget.course.courseReferenceId),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionManager extends StatefulWidget {
  final String courseId;
  final Function setCurrentSessionId;
  const SessionManager(
      {super.key, required this.courseId, required this.setCurrentSessionId});

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> {
  List<Session> sessions = [];
  bool isLoading = true;

  Future<void> fetchSessions() async {
    var sessions = await getSessions(
        widget.courseId); // Assume this now returns List<Session>
    setState(() {
      this.sessions = sessions;
      isLoading = false;
    });
  }

  Future<void> createSession() async {
    setState(() {
      isLoading = true;
    });
    String sessionId = await markAttendance(widget.courseId);
    widget.setCurrentSessionId(sessionId);
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
            onPressed: isLoading ? null : () {
              createSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.blueAccent, // A more vibrant shade of blue
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.0), // Softer rounded corners
              ),
              elevation:
                  3, // Slightly higher elevation for a more pronounced shadow
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12), // Improved padding for a better tactile feel
              textStyle: const TextStyle(
                letterSpacing:
                    1.2, // Increase letter spacing for a more open look
              ),
            ),
            child: const Text(
              'Start Session & Attendance',
              style: TextStyle(
                fontSize: 16, // Slightly larger text for better readability
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const SizedBox(
                      height: 8), // Adjust for spacing between cards
                  itemBuilder: (context, index) {
                    final session = sessions[sessions.length - index - 1];
                    return SessionCard(
                        session: session,
                        setCurrentSessionId: widget.setCurrentSessionId);
                  },
                ),
        ),
      ],
    );
  }
}

class AttendanceResultOfToday extends StatefulWidget {
  final String sessionId;
  final String courseId;
  final Database database;

  const AttendanceResultOfToday(
      {super.key,
      required this.sessionId,
      required this.courseId,
      required this.database});

  @override
  State<AttendanceResultOfToday> createState() =>
      _AttendanceResultOfTodayState();
}

class _AttendanceResultOfTodayState extends State<AttendanceResultOfToday> {
  bool updating = false;
  String findTodaysTotalAttendance(List<Student> allStudents) {
    int count = 0;
    for (var student in allStudents) {
      if (student.isPresent) {
        count++;
      }
    }
    return "$count/${allStudents.length}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Student>>(
      future:
          widget.database.getPresentStudents(widget.courseId, widget.sessionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return buildErrorWidget(context, snapshot.error, () {
            setState(() {});
          });
        } else {
          List<Student> allStudents = snapshot.data!;
          String todaysTotalAttendance = findTodaysTotalAttendance(allStudents);
          return updating
          ? const CircularProgressIndicator()
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      updating = true;
                    });
                    await markAttendance(widget.courseId, sessionId: widget.sessionId);
                    setState(() {
                      updating = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Softer rounded corners
                    ),
                    elevation: 3, // Slightly higher elevation for a more pronounced shadow
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Improved padding for a better tactile feel
                    textStyle: const TextStyle(
                      letterSpacing: 1.2, // Increase letter spacing for a more open look
                      fontSize: 16, // Slightly larger text for better readability
                    ),
                  ),
                  child: const Text(
                    'Take Attendance',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Today\'s Attendance',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      todaysTotalAttendance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    allStudents.length,
                    (index) {
                      final student = allStudents[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(student.entryNumber),
                            leading: Icon(
                              student.isPresent ? Icons.check : Icons.close,
                              color: student.isPresent ? Colors.green : Colors.red,
                            ),
                            trailing: Switch(
                              value: student.isPresent,
                              onChanged: (newValue) async {
                                setState(() {
                                  updating = true;
                                });
                                await widget.database.markstudentInCourseOnSession(widget.courseId, widget.sessionId, student.entryNumber, newValue);
                                setState(() {
                                  updating = false;
                                });
                              },
                              activeColor: Colors.green, // Color when switch is ON
                              inactiveThumbColor: Colors.red, // Color when switch is OFF
                              activeTrackColor: Colors.green.withOpacity(0.5), // Color of the track when switch is ON
                              inactiveTrackColor: Colors.red.withOpacity(0.5), // Color of the track when switch is OFF
                            ),
                          ),
                          if (index != allStudents.length - 1) // Add divider between students except for the last one
                            const Divider(height: 1, thickness: 1),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      },
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
      {super.key,
      required this.course,
      required this.database,
      required this.onUpdate});

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
                        hintText: 'Enter Lowercase Entry no. '),
                    onChanged: (value) {
                      setState(() {
                        studentId = value;
                      });
                    }),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await widget.database.addStudentToCourse(
                          studentId, widget.course.courseReferenceId);
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
                        hintText: 'Enter Lowercase Entry no. '),
                    onChanged: (value) {
                      setState(() {
                        studentId = value;
                      });
                    }),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await widget.database.removeStudentFromCourse(
                          studentId, widget.course.courseReferenceId);
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
                      await widget.database
                          .deleteCourse(widget.course.courseReferenceId);
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
  String _statusMessage = '';

  @override

  Future<Map<String, dynamic>> getStudentsMarks(String courseId) async{
    CollectionReference marksCollection = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Marks');
    Map<String, dynamic> marksData = {};
    bool isempty = true;

    await marksCollection.get().then((QuerySnapshot querySnapshot){
      int numberOfStudents = querySnapshot.size-1;
      querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if(doc.id != 'max'){
        if(isempty){
          marksData.addAll(data);
          isempty = false;
        } else{
          data.forEach((key, value) {
            marksData[key] += (value ?? 0);
          });
        }
      }
      });
      if(numberOfStudents > 0){
        marksData.forEach((key, value) {
          marksData[key] = value/numberOfStudents;
        });
      }
    });
    return marksData;
  }

  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green[600], // A more vibrant shade of blue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Softer rounded corners
                  ),
                  elevation:
                      5, // Slightly higher elevation for a more pronounced shadow
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical:
                          12), // Improved padding for a better tactile feel
                  textStyle: const TextStyle(
                    letterSpacing:
                        1.2, // Increase letter spacing for a more open look
                  ),
                ),
                onPressed: _pickAndUploadCSV,
                child: const Text(
                  'Pick and Upload CSV',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              child: const Icon(
                Icons.info,
                size: 32,
              ),
              onTap: (){
                showDialog(
                  context: context,
                  builder: (BuildContext content){
                    return AlertDialog(
                      title: const Text('Required CSV Format', style: TextStyle(fontSize: 20),),
                      content: Image.asset('assets/CSV_format.png', height: MediaQuery.of(context).size.height*0.25, width: MediaQuery.of(context).size.width*1, fit: BoxFit.fill),
                    );
                  });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _statusMessage,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 15,
        ),
        FutureBuilder(
              future: getStudentsMarks(widget.courseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return buildErrorWidget(context, snapshot.error, () {setState(() {});});
                }
                final stats = snapshot.data as Map<String, dynamic>;
                return StudentsAverageStats(
                  
                  marks: stats,
                );
              },
              ),
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

class StudentsAverageStats extends StatelessWidget {
  final Map<String, dynamic> marks;

  const StudentsAverageStats({
    super.key,
    required this.marks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Average Marks',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: marks.length,
                    itemBuilder: (context, index) {
                      final entry = marks.entries.toList()[index];
                      final quizTitle = marks.keys.toList()[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index != 0) // Add a divider before each quiz except the first one
                            const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              quizTitle,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Average Marks:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
