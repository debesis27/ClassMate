import 'package:ClassMate/Datasource/dummy_courses_list.dart';
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
  // ignore: library_private_types_in_public_api
  _TeacherHomePage createState() => _TeacherHomePage();
}

class _TeacherHomePage extends State<TeacherHomePage> {

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Database database = Database(user: widget.user);
    List<Course> allCourses = dummyCourses;

    return FutureBuilder(
      future: database.getUserCourses(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SkeletonHomeScreen(
            auth: widget.auth,
            user: widget.user,
            database: database,
            onUpdate: update,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }else{
          allCourses = snapshot.data;
          return TeacherHomeScreenScaffold(
            auth: widget.auth,
            user: widget.user,
            database: database,
            allCourses: allCourses,
            onChanged: update,
          );
        }
      }
    );
  }
}

class TeacherHomeScreenScaffold extends StatelessWidget {
  const TeacherHomeScreenScaffold({
    super.key,
    required this.allCourses,
    required this.auth,
    required this.user,
    required this.database,
    required this.onChanged,
  });

  final List<Course> allCourses;
  final FirebaseAuth auth;
  final User user;
  final Database database;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        backgroundColor: Colors.blue,
      ),
      drawer: MyNavigationDrawer(
        allCourses: allCourses,
        isTeacher: true,
        auth: auth,
        user: user,
        database: database,
        currentPage: "Classes",
        onUpdate: onChanged,
      ),
      body: AllCoursesList(
        allCourses: allCourses,
        isTeacher: true,
        database: database,
        onUpdate: onChanged
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewCourse(user: user, onUpdate: onChanged)
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
}