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

  @override
  Widget build(BuildContext context) {
    final User user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZooP- Add New Course', style: TextStyle(fontSize: 25),),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          // Course Details
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Course Details:', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),),
          ),

          // Course Title
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
            child: TextField(
              onChanged: (value){
                setState(() {
                  courseTitle = value;
                });
              },
                decoration: const InputDecoration(
                    hintText: 'Enter Course Title'
                )
            ),
          ),

          // Course Code
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
            child: TextField(
              onChanged: (value){
                setState(() {
                  courseCode = value;
                });
              },
                decoration: const InputDecoration(
                    hintText: 'Enter Course Code'
                )
            ),
          ),

          // Academic Year
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
            child: TextField(
              onChanged: (value){
                setState(() {
                  academicYear = value;
                });
              },
                decoration: const InputDecoration(
                    hintText: 'Enter Academic Year'
                )
            ),
          ),
          // Add optional image
          // For later

          // Create Course Button
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                  ),
                ),
                onPressed: () async {
                  Database database = Database(user: user);
                  await database.getUserCourses();
                  final List<String> teachingCoursesId = database.teachingCoursesId;

                  String courseId = await Database(user: user).addCourse(Course(courseTitle: courseTitle, courseCode: courseCode, instructorName: user.displayName ?? "", academicYear: academicYear, instructorUid: user.uid, image: r'assets/mathematics.jpg'));
                  teachingCoursesId.add(courseId);
                  Database(user: user).updateTeacherCourses(teachingCoursesId);
                  Navigator.pop(context, true);
                  String output = 'Course created with Course ID: $courseId';
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        Future.delayed(const Duration(seconds: 1), (){
                          Navigator.of(context).pop(true); // pop dialog box after 1 sec.
                        });
                        return AlertDialog(
                          content: Text(output, style: const TextStyle(fontSize: 18),),
                        );
                      });
                },
                child: const Text('Create Course', style: TextStyle(fontSize: 18),)),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                  )
                ),
                onPressed: (){
                  Navigator.pop(context, true);
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        Future.delayed(const Duration(seconds: 1), (){
                          Navigator.of(context).pop(true); // pop dialog box after 1 sec.
                        });
                        return const AlertDialog(
                          content: Text('Course creation failed.', style: TextStyle(fontSize: 20),),
                        );
                      });
                },
                child: const Text('Cancel', style: TextStyle(fontSize: 18),)),
          )
        ],
      )

    );
  }
}
