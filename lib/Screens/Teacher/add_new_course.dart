// import 'package:ClassMate/Firebase/NewClassFirebase.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ClassMate/Models/course_info_model.dart';

class AddNewCourse extends StatefulWidget {
  final User user;

  AddNewCourse({super.key, required this.user});
  @override
  State<AddNewCourse> createState() => _AddNewCourseState();
}

class _AddNewCourseState extends State<AddNewCourse> {
  String courseTitle = '';
  String courseCode = '';
  String academicYear = '';

  void saveInputs(user) async {
    Database database = Database(user: user);
    //TODO: Use below thing to avoid duplication of classes
    await database.getUserCourses();
    final List<String> teachingCoursesId = database.teachingCoursesId;

    String courseId = await Database(user: user).addCourse(Course(
        courseTitle: courseTitle,
        courseCode: courseCode,
        instructorName: user.displayName ?? "",
        academicYear: academicYear,
        instructorUid: user.uid,
        image: r'assets/mathematics.jpg'));
    teachingCoursesId.add(courseId);
    Database(user: user).updateTeacherCourses(teachingCoursesId);
    Navigator.pop(context, true);
    String output = 'Course created with Course ID: $courseId';
    //TODO: Make it better
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true); // pop dialog box after 1 sec.
          });
          return AlertDialog(
            content: Text(
              output,
              style: const TextStyle(fontSize: 18),
            ),
          );
        });
    // firebaseclasssetup(courseCode, courseTitle, academicYear, newCourse.instructor, newCourse.image);
  }

  // void courseCreationFailure() {
  //   Navigator.pop(context, true);
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         Future.delayed(const Duration(seconds: 1), () {
  //           Navigator.of(context).pop(true); // pop dialog box after 1 sec.
  //         });
  //         return const AlertDialog(
  //           content: Text(
  //             'Course creation failed.',
  //             style: TextStyle(fontSize: 20),
  //           ),
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    final User user = widget.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Set the background color to blue
        title: const Text('Add New Course'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: const Text(
                      'Course Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        courseCode = value;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: const Text(
                      'Course Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        courseTitle = value;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: const Text(
                      'Academic Year',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        academicYear = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            //TODO: Add image upload
            ElevatedButton(
              onPressed: () {
                saveInputs(user);
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                minimumSize: const Size(double.infinity, 48.0),
              ),
              child: const Text('Save'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                minimumSize: const Size(double.infinity, 48.0),
              ),
              child: const Text('Cancel'),
            )
          ],
        ),
      )),
    );
  }
}
