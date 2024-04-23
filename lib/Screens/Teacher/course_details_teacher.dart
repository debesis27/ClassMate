import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.code),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: TakeAttendance(),
            ),
            Center(
              child: Text('Stats for ${course.code}'),
            ),
          ],
        ),
      ),
    );
  }
}

class TakeAttendance extends StatelessWidget{
  const TakeAttendance({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          //TODO: Add function to take attendance
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendanceResultOfToday())
          );
        },
        child: const Text('Take Attendance'),
      )
    );
  }
}

class AttendanceResultOfToday extends StatelessWidget{
  const AttendanceResultOfToday({super.key});

  @override
  Widget build(BuildContext context){
    return const Column(
      children: [
        Text("Today's Attendance: 10/20"), //TODO: Add function to get number of student present and total number of students
        //TODO: Add function to get list of students present and absent
      ],
    );
  }
}

class AttendanceStats extends StatelessWidget{
  const AttendanceStats({super.key});
  
  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: 10, //TODO: Add function to get number of students in the course
      itemBuilder: (context, index){
        
      }
    );
  }
}
