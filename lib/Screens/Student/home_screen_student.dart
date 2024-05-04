import 'package:ClassMate/Screens/common_screen_widgets.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ClassMate/Models/course_info_model.dart';

class StudentHomePage extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  
  const StudentHomePage({super.key, required this.auth, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _StudentHomePage createState() => _StudentHomePage();
}

class _StudentHomePage extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = widget.auth;
    final User user = widget.user;
    Database database = Database(user: user);    
    return FutureBuilder(
      future: database.getUserCourses(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SkeletonHomeScreen(
            auth: widget.auth,
            user: widget.user,
            database: database,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Course> allCourses = snapshot.data;
          return StudentHomePageScaffold(
            auth: auth,
            user: user,
            database: database,
            allCourses: allCourses
          );
        }
      },
    );
  }
}

class StudentHomePageScaffold extends StatefulWidget {
  final FirebaseAuth auth;
  final User user; 
  final Database database;
  final List<Course> allCourses;

  const StudentHomePageScaffold({super.key, required this.auth, required this.user, required this.database, required this.allCourses});

  @override
  State<StudentHomePageScaffold> createState() => _StudentHomePageScaffoldState();
}

class _StudentHomePageScaffoldState extends State<StudentHomePageScaffold> {
  @override
  Widget build (BuildContext context) {
    String courseCode = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Classes'),
        backgroundColor: Colors.blue,
      ),
      drawer: MyNavigationDrawer(allCourses: widget.allCourses, isTeacher: false, auth: widget.auth, user: widget.user, database: widget.database, currentPage: "Classes",),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Enter class code'),
                content: TextField(
                  onChanged: (value) {
                    setState(() {
                      courseCode = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter Class code',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      widget.database.joinCourse(courseCode);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: const Icon(Icons.add),
      ),
      body: AllCoursesList(allCourses: widget.allCourses, isTeacher: false, database: widget.database,),
    );
  }
}
