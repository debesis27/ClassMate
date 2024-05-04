import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/Screens/account_page.dart';
import 'package:ClassMate/Screens/common_utils.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'Student/course_details_student.dart';
import 'Teacher/course_details_teacher.dart';
import '../Datasource/images_data.dart';

class AllCoursesList extends StatelessWidget {
  const AllCoursesList({
    super.key,
    required this.allCourses,
    required this.isTeacher,
    required this.database,
  });

  final List<Course> allCourses;
  final bool isTeacher;
  final Database database;

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
                          )
                        : StudentCourseDetailScreen(
                            course: course,
                            database: database,
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

  const MyNavigationDrawer({
    super.key,
    required this.isTeacher,
    required this.auth,
    required this.user,
    required this.database,
    required this.allCourses,
    required this.currentPage,
  });

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    Widget homePage;
    final FirebaseAuth auth = widget.auth;
    final User user = widget.user;

    if (widget.isTeacher) {
      homePage = TeacherHomePage(
        auth: auth,
        user: user,
      );
    } else {
      homePage = StudentHomePage(
        auth: auth,
        user: user,
      );
    }

    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 100, // Adjust the height as needed
            child: DrawerHeader(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: Colors.blue,
              ),
              child: Text(
                'ClassMate',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Account'),
            onTap: () {
              widget.currentPage == "Account"
                  ? Navigator.pop(context)
                  : {
                      Navigator.pop(context),
                      Navigator.pop(context),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountPage(
                                  auth: auth,
                                  user: user,
                                  allCourses: widget.allCourses,
                                  isTeacher: widget.isTeacher)))
                    };
            },
          ),
          ListTile(
            title: const Text('Classes'),
            onTap: () {
              widget.currentPage == "Classes"
                  ? Navigator.pop(context)
                  : {
                      Navigator.pop(context),
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => homePage)),
                    };
            },
          ),
          // ListTile(
          //   title: const Text('Tasks'),
          //   onTap: () {
          //     // Handle Tasks button tap
          //   },
          // ),
          const Divider(),
          const ListTile(
            title: Text(
              'All Classes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: widget.allCourses.map((course) {
              return ListTile(
                title: Text(course.courseCode),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.isTeacher
                          ? TeacherCourseDetailScreen(
                              course: course, database: widget.database)
                          : StudentCourseDetailScreen(
                              course: course, database: widget.database),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SkeletonHomeScreen extends StatelessWidget {
  final FirebaseAuth auth;
  final User user;
  final Database database;

  const SkeletonHomeScreen({super.key, required this.auth, required this.user, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        backgroundColor: Colors.blue,
      ),
      drawer: MyNavigationDrawer(
        allCourses: const [],
        isTeacher: true,
        auth: auth,
        user: user,
        database: database,
        currentPage: "Classes",
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
