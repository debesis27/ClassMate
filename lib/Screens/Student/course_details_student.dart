import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Models/session_info.dart';
import 'package:ClassMate/Screens/common_screen_widgets.dart';
import 'package:ClassMate/Screens/error_page.dart';
import 'package:ClassMate/bluetooth/advertising.dart';
import 'package:ClassMate/services/database.dart';
import 'package:ClassMate/services/get_sessions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final Course course;
  final Database database;
  final Function onUpdate;

  const StudentCourseDetailScreen({super.key, required this.course, required this.database, required this.onUpdate});

  @override
  _StudentCourseDetailScreenState createState() => _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> with WidgetsBindingObserver {
  String currentSessionId = '';

  void reload () {
    setState(() {});
  }

  void setCurrentSessionId(String sessionId) {
    setState(() {
      currentSessionId = sessionId;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAdvertising(); // Call stopAdvertising when the screen is disposed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      stopAdvertising(); // Optionally handle pausing the ad when the app is in background
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.course.courseCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 4.0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Stats'),
            ],
          ),
          actions: [
            GestureDetector(
                onTap: () {setState(() {});},
                child: const Icon(Icons.refresh, size: 28, semanticLabel: 'Refresh')
              ),
            CourseSettings(course: widget.course, database: widget.database, onUpdate: widget.onUpdate,),
          ]
        ),
        body: TabBarView(
          children: [
            Center(
              child: currentSessionId == ""
                ? SessionManager(courseId: widget.course.courseReferenceId, entryNumber: widget.database.user.email!.substring(0, 11), setCurrentSessionId: setCurrentSessionId)
                : AttendanceResultOfToday(sessionId: currentSessionId, courseId: widget.course.courseReferenceId, database: widget.database),
            ),
            FutureBuilder(
              future: widget.database.getStudentStats(widget.course.courseReferenceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return buildErrorWidget(context, snapshot.error, () {setState(() {});});
                }
                final stats = snapshot.data as Map<String, dynamic>;
                return StudentStats(
                  presentCount: stats['presentCount'],
                  totalCount: stats['totalCount'],
                  quizMarks: stats['Marks'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SessionManager extends StatefulWidget {
  final String courseId;
  final String entryNumber;
  final Function setCurrentSessionId;

  const SessionManager({super.key, required this.courseId, required this.entryNumber, required this.setCurrentSessionId});

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> {
  List<Session> sessions = [];
  bool isLoading = true;
  bool isAdvertising = false;

  Future<void> fetchSessions() async {
    var sessions = await getSessions(widget.courseId);  // Assume this now returns List<Session>
    setState(() {
      this.sessions = sessions;
      isLoading = false;
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
                  onPressed: isAdvertising ? null : () async {
                    setState(() {
                      isAdvertising = true;
                    });
                    await startAdvertising(id: widget.entryNumber);
                    // stop after 30 seconds
                    await Future.delayed(const Duration(seconds: 60), () {
                      stopAdvertising();
                    });
                    setState(() {
                      isAdvertising = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // A more vibrant shade of blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Softer rounded corners
                    ),
                    elevation: 3, // Slightly higher elevation for a more pronounced shadow
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Improved padding for a better tactile feel
                    textStyle: const TextStyle(
                      letterSpacing: 1.2, // Increase letter spacing for a more open look
                    ),
                  ),
                  child: const Text(
                    'Mark Attendance',
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
                  separatorBuilder: (context, index) => const SizedBox(height: 8), // Adjust for spacing between cards
                  itemBuilder: (context, index) {
                    final session = sessions[sessions.length - index - 1];
                    return SessionCard(session: session, setCurrentSessionId: widget.setCurrentSessionId);
                  },
                ),
        ),
      ],
    );
  }
}

class AttendanceResultOfToday extends StatelessWidget {
  final String sessionId;
  final String courseId;
  final Database database;
  bool isPresent = false;

  AttendanceResultOfToday({super.key, required this.sessionId, required this.courseId, required this.database, this.isPresent = false});

  @override
  Widget build (BuildContext context) {
    return FutureBuilder<bool>(
      future: database.isStudentPresentInCourseOnSession(courseId, sessionId).then((value) => isPresent = value),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }else if(snapshot.hasError){
          return const Center(child: Text('Error fetching attendance data'));
        }else{
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPresent ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                  color: isPresent ? Colors.green : Colors.red,
                  size: 100,
                ),
                Text(
                  isPresent ? 'You have been marked present' : 'You have been marked absent',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
      }
    );
  }
}

class StudentStats extends StatelessWidget {
  final int presentCount;
  final int totalCount;
  final Map<String, dynamic> quizMarks;

  const StudentStats({
    super.key,
    required this.presentCount,
    required this.totalCount,
    required this.quizMarks,
  });

  @override
  Widget build(BuildContext context) {
    String attendancePercentage = presentCount/totalCount * 100 == 0 ? '0' : (presentCount/totalCount * 100).toStringAsFixed(2);

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
                    'Attendance Stats',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Attendance:',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$presentCount/$totalCount ',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                    'Marks',
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
                    itemCount: quizMarks.length,
                    itemBuilder: (context, index) {
                      final entry = quizMarks.entries.toList()[index];
                      final quizTitle = quizMarks.keys.toList()[index];
                      if(quizTitle == 'No Marks Available'){
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              quizTitle,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                      }
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
                                'Your Marks:',
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

class CourseSettings extends StatelessWidget {
  final Course course;
  final Database database;
  final Function onUpdate;

  const CourseSettings(
      {super.key, required this.course, required this.database, required this.onUpdate});

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
                      style: const TextStyle(fontSize: 15),
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
                      await database.studentLeaveCourse(course.courseReferenceId);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      await onUpdate();
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
