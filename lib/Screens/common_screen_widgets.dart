import 'package:ClassMate/Login/login_screen.dart';
import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:flutter/material.dart';
import 'Student/course_details.dart';

class AllCoursesList extends StatelessWidget {
  const AllCoursesList({
    super.key,
    required this.allCourses,
  });

  final List<Course> allCourses;

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
                    builder: (context) => CourseDetailScreen(course: course),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(course.image),
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
                          '${course.code} - ${course.title}',
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
                      course.instructor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
        );
      },
    );
  }
}

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({
    super.key,
    required this.allCourses,
    required this.isTeacher,
  });

  final List<Course> allCourses;
  final bool isTeacher;

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    Widget homePage;
    if(widget.isTeacher) {
      homePage = const TeacherHomePage();
    } else {
      homePage = const StudentHomePage();
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
              // Handle Account button tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
          ListTile(
            title: const Text('Classes'),
            onTap: () {
              // Handle Classes button tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => homePage));
            },
          ),
          ListTile(
            title: const Text('Tasks'),
            onTap: () {
              // Handle Tasks button tap
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
          Column(
            children: widget.allCourses.map((course) {
              return ListTile(
                title: Text(course.code),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
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
