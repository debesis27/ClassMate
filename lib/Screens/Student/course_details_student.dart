import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Models/session_info.dart';
import 'package:ClassMate/bluetooth/advertising.dart';
// import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:ClassMate/services/database.dart';
import 'package:ClassMate/services/get_sessions.dart';
// import 'package:ClassMate/services/mark_attendence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StudentCourseDetailScreen extends StatefulWidget {
  final Course course;
  final Database database;
  final Function onUpdate;

  const StudentCourseDetailScreen({super.key, required this.course, required this.database, required this.onUpdate});

  @override
  _StudentCourseDetailScreenState createState() => _StudentCourseDetailScreenState();
}

class _StudentCourseDetailScreenState extends State<StudentCourseDetailScreen> with WidgetsBindingObserver {
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
            CourseSettings(course: widget.course, database: widget.database, onUpdate: widget.onUpdate,),
          ]
        ),
        body: TabBarView(
          children: [
            Center(
              child: SessionManager(courseId: widget.course.courseReferenceId, entryNumber: widget.database.user.email!.substring(0, 11)),
            ),
            Center(
              child: Text('Stats for ${widget.course.courseCode}'),
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
  const SessionManager({super.key, required this.courseId, required this.entryNumber});

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
                  separatorBuilder: (context, index) => SizedBox(height: 8), // Adjust for spacing between cards
                  itemBuilder: (context, index) {
                    final session = sessions[sessions.length - index - 1];
                    // Determine if the session's year is the current year
                    bool isCurrentYear = DateTime.now().year == session.datetime.year;
                    return Card(
                      elevation: 2, // Adds shadow to create an elevated effect
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Margin to space out the cards
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners for a smoother look
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding inside the card
                        child: ListTile(
                          leading: const Icon(Icons.event, color: Color.fromARGB(162, 0, 0, 0)), // Icon for visual identification
                          title: Text(
                            DateFormat(isCurrentYear ? 'EEE, MMM d' : 'EEE, MMM d, yyyy').format(session.datetime),
                            style: const TextStyle(
                              fontSize: 18, // Larger font for date
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(196, 0, 0, 0), // Slightly dark color for emphasis
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('HH:mm').format(session.datetime), // Time displayed smaller
                            style: const TextStyle(
                              fontSize: 14, // Smaller font size for time
                              color: Color.fromARGB(104, 0, 0, 0), // A lighter shade for contrast
                            ),
                          ),
                          onTap: () {
                            // Implement your onTap functionality here
                            // widget.setCurrentSessionId(session.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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
