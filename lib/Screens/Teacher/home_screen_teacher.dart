import 'package:ClassMate/Screens/Teacher/add_new_course.dart';
import 'package:ClassMate/Screens/common_screen_widgets.dart';
import 'package:ClassMate/services/database.dart';
// import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ClassMate/Models/course_info_model.dart';

class TeacherHomePage extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  const TeacherHomePage({super.key, required this.auth, required this.user});

  @override
  _TeacherHomePage createState() => _TeacherHomePage();
}

class _TeacherHomePage extends State<TeacherHomePage> {
  // List<Course> allCourses = [
  //   Course(
  //     courseCode: 'MA517',
  //     courseTitle: 'Distributed Algorithms',
  //     academicYear: '2023-24',
  //     instructor: 'Kaushik Mondal',
  //     image: 'assets/mathematics.jpg',
  //   ),
  //   Course(
  //     courseCode: 'MA302',
  //     courseTitle: 'Optimization Techniques',
  //     academicYear: '2023-24',
  //     instructor: 'Arti Pandey',
  //     image: 'assets/physics.jpg',
  //   ),
  //   Course(
  //     courseCode: 'HS301',
  //     courseTitle: 'Operation Management',
  //     academicYear: '2023-24',
  //     instructor: 'Ravi Kumar',
  //     image: 'assets/chemistry.jpg',
  //   ),
  //   Course(
  //     courseCode: 'CS503',
  //     courseTitle: 'Machine Learning',
  //     academicYear: '2023-24',
  //     instructor: 'Shashi Shekhar Jha',
  //     image: 'assets/biology.jpg',
  //   ),
  //   Course(
  //     courseCode: 'CS204',
  //     courseTitle: 'Computer Architecture',
  //     academicYear: '2023-24',
  //     instructor: 'Neeraj Goel',
  //     image: 'assets/history.jpg',
  //   ),
  //   Course(
  //     courseCode: 'CP301',
  //     courseTitle: 'DEP',
  //     academicYear: '2023-24',
  //     instructor: 'Arti Pandey',
  //     image: 'assets/english.jpg',
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = widget.auth;
    final User user = widget.user;
    Database database = Database(user: user);

    return FutureBuilder(
      future: database.getUserCourses(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error if there is any
        } else {
          List<Course> allCourses = snapshot.data;
          
          // building the scaffold
          return Scaffold(
            appBar: AppBar(
              title: const Text('Teacher Classes'),
              backgroundColor: Colors.blue,
            ),
            drawer: MyNavigationDrawer(
              allCourses: allCourses,
              isTeacher: true,
              auth: auth,
              user: user,
              database: database,
              currentPage: "Classes",
            ),
            body: AllCoursesList(
              allCourses: allCourses,
              isTeacher: true,
              database: database,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewCourse(user: user)
                  ),
                );
              },
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
