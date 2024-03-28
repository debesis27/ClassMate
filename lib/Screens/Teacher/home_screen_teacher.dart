import 'package:ClassMate/Screens/Teacher/add_new_course.dart';
import 'package:ClassMate/Screens/common_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:ClassMate/Models/course_info_model.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  _TeacherHomePage createState() => _TeacherHomePage();
}

class _TeacherHomePage extends State<TeacherHomePage> {
  List<Course> allCourses = [
    Course(
      code: 'MA517',
      title: 'Distributed Algorithms',
      academicYear: '2023-24',
      instructor: 'Kaushik Mondal',
      image: 'assets/mathematics.jpg',
    ),
    Course(
      code: 'MA302',
      title: 'Optimization Techniques',
      academicYear: '2023-24',
      instructor: 'Arti Pandey',
      image: 'assets/physics.jpg',
    ),
    Course(
      code: 'HS301',
      title: 'Operation Management',
      academicYear: '2023-24',
      instructor: 'Ravi Kumar',
      image: 'assets/chemistry.jpg',
    ),
    Course(
      code: 'CS503',
      title: 'Machine Learning',
      academicYear: '2023-24',
      instructor: 'Shashi Shekhar Jha',
      image: 'assets/biology.jpg',
    ),
    Course(
      code: 'CS204',
      title: 'Computer Architecture',
      academicYear: '2023-24',
      instructor: 'Neeraj Goel',
      image: 'assets/history.jpg',
    ),
    Course(
      code: 'CP301',
      title: 'DEP',
      academicYear: '2023-24',
      instructor: 'Arti Pandey',
      image: 'assets/english.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Classes'),
        backgroundColor: Colors.blue,
      ),
      drawer: MyNavigationDrawer(allCourses: allCourses, isTeacher: true),
      body: AllCoursesList(allCourses: allCourses),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewCourse()),
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
