import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Models/session_info.dart';
// import 'package:ClassMate/Screens/Student/home_screen_student.dart';
// import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/Screens/account_page.dart';
import 'package:ClassMate/Screens/common_utils.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'Student/course_details_student.dart';
import 'Teacher/course_details_teacher.dart';
import '../Datasource/images_data.dart';

// builds a list of all courses for the user
class AllCoursesList extends StatelessWidget {
  const AllCoursesList({
    super.key,
    required this.allCourses,
    required this.isTeacher,
    required this.database,
    required this.onUpdate
  });

  final List<Course> allCourses;
  final bool isTeacher;
  final Database database;
  final Function onUpdate;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allCourses.length,
      itemBuilder: (context, index) {
        Course course = allCourses[index];
        return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isTeacher
                        ? TeacherCourseDetailScreen(
                            course: course,
                            database: database,
                            onUpdate: onUpdate
                          )
                        : StudentCourseDetailScreen(
                            course: course,
                            database: database,
                            onUpdate: onUpdate,
                          ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: images[stringToInt(course.image)].image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${course.courseCode} - ${course.courseTitle}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AY: ${course.academicYear}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      course.instructorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

class MyNavigationDrawer extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  final Database database;
  final bool isTeacher;
  final List<Course> allCourses;
  final String currentPage;
  final Function onUpdate;


  const MyNavigationDrawer({
    super.key,
    required this.isTeacher,
    required this.auth,
    required this.user,
    required this.database,
    required this.allCourses,
    required this.currentPage,
    required this.onUpdate
  });

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    // Widget homePage;
    final FirebaseAuth auth = widget.auth;
    // final User user = widget.user;

    // if (widget.isTeacher) {
    //   homePage = TeacherHomePage(
    //     auth: auth,
    //     user: user,
    //   );
    // } else {
    //   homePage = StudentHomePage(
    //     auth: auth,
    //     user: user,
    //   );
    // }

   return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,  // Remove default padding for full usage of space
      children: [
        SizedBox(
          height: 120, // Adjusted height for better visual impact
          child: DrawerHeader(
            margin: EdgeInsets.zero,  // Use the entire space for header
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Use theme's primary color for consistency
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              'ClassMate',
              style: TextStyle(
                fontSize: 28, // Increased size for better visibility
                color: Colors.black,
                fontWeight: FontWeight.bold, // Bold for emphasis
              ),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.account_circle, color: Theme.of(context).iconTheme.color),  // Icons for better UX
          title: const Text('Account'),
          onTap: () {
            widget.currentPage == "Account"
                ? Navigator.pop(context)
                : {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountPage(
                                auth: auth,
                                allCourses: widget.allCourses,
                                isTeacher: widget.isTeacher,
                                database: widget.database,
                                onUpdate: widget.onUpdate,)))
                  };
          },
        ),
        ListTile(
          leading: Icon(Icons.class_, color: Theme.of(context).iconTheme.color), // Icons for classes
          title: const Text('Classes'),
          onTap: () {
            widget.currentPage == "Classes"
                ? Navigator.pop(context)
                : {
                    Navigator.pop(context),
                    Navigator.pop(context),
                  };
          },
        ),
        const Divider(),
        const ListTile(
          title: Text(
            'All Classes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...widget.allCourses.map((course) {  // Use spread operator for cleaner code
          return ListTile(
            leading: Icon(Icons.book, color: Theme.of(context).iconTheme.color),  // Icons for each course
            title: Text(course.courseCode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.isTeacher
                      ? TeacherCourseDetailScreen(
                          course: course, database: widget.database, onUpdate: widget.onUpdate,)
                      : StudentCourseDetailScreen(
                          course: course, database: widget.database, onUpdate: widget.onUpdate,),
                ),
              );
            },
          );
        }).toList(),
      ],
    ),
  );

  }
}

class SkeletonHomeScreen extends StatelessWidget {
  final FirebaseAuth auth;
  final User user;
  final Database database;
  final Function onUpdate;

  const SkeletonHomeScreen(
      {super.key,
      required this.auth,
      required this.user,
      required this.database,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classes',
          style: TextStyle(
            fontSize: 25, // Increase font size for better visibility
            fontWeight: FontWeight.bold, // Added font weight for better readability
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: MyNavigationDrawer(
        allCourses: const [],
        isTeacher: true,
        auth: auth,
        user: user,
        database: database,
        currentPage: "Classes",
        onUpdate: onUpdate,
      ),
      body: skeletonCards(),
    );
  }

  Skeletonizer skeletonCards() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    width: 100,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({
    Key? key,
    required this.session,
    required this.setCurrentSessionId,
  }) : super(key: key);

  final Session session;
  final Function setCurrentSessionId;

  @override
  Widget build(BuildContext context) {
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
          leading: const Icon(Icons.event, color: Color.fromARGB(162, 0, 0, 0), size: 35), // Icon for visual identification
          title: Text(
            'Session - ${session.id}',
            style: const TextStyle(
              fontSize: 18, // Larger font for session ID
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(196, 0, 0, 0), // Slightly dark color for emphasis
            ),
          ),
          subtitle: Text(
            DateFormat(isCurrentYear ? 'EEE, MMM d' : 'EEE, MMM d, yyyy').format(session.datetime),
            style: const TextStyle(
              fontSize: 14, // Smaller font size for date
              color: Color.fromARGB(104, 0, 0, 0), // A lighter shade for contrast
            ),
          ),
          trailing: Text(
            DateFormat('HH:mm').format(session.datetime), // Time displayed as trailing text
            style: const TextStyle(
              fontSize: 14, // Smaller font size for time
              color: Color.fromARGB(104, 0, 0, 0), // A lighter shade for contrast
            ),
          ),
          onTap: () {
            // Implement your onTap functionality here
            setCurrentSessionId(session.id);
          },
        ),
      ),
    );
  }
}
