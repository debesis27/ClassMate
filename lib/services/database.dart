import 'package:ClassMate/Models/course_info_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';

class Database {
  final User user;
  Database({required this.user});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final CollectionReference courseCollection = FirebaseFirestore.instance.collection('Courses');
  List<Course> courses = [];
  List<String> teachingCoursesId = [];
  List<String> studyingCoursesId = [];


  Future<bool> isTeacher() async {
    final User user = this.user;
    DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
    if (!doc.exists) {
      return false;
    }
    return doc['isTeacher'];
  }

  // For new user if Teacher
  void setTeachersCollection() async {
    return await usersCollection.doc(user.uid).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': true,
      'teachingCoursesId': [],
      'studyingCoursesId' : []
    });
  }

  // For new user if Student
  void setStudentsCollection() async{
    return await usersCollection.doc(user.uid).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': false,
      'teachingCoursesId' : [],
      'studyingCoursesId' : []
    });
  }

  
  Future<void> deleteUser(){
    return usersCollection.doc(user.uid).delete();
  }
  
  
  void updateTeacherCourses(List<String> coursesIdList) async{
    return await usersCollection.doc(user.uid).update({'teachingCoursesId' : coursesIdList});
  }
  
  void updateStudentCourses(List<String> courseIdList) async{
    return await usersCollection.doc(user.uid).update({'studyingCoursesId' : courseIdList});
  }

  // For new course
  Future<String> addCourse(Course course) async{
    DocumentReference courseRef =  await courseCollection.add({
      'Title': course.courseTitle,
      'Code': course.courseCode,
      'Academic Year': course.academicYear,
      'Instructor Name': course.instructorName,
      'Instructor Uid': course.instructorUid,
      'Students Name': [],
      'Students Uid': [],
      'Attendance list': [],
      'image': course.image
    });
    String courseId = courseRef.id;
    return courseId;
  }

  void addUserToCourse({required String courseId, required List<String> studentsNameList, required List<String> studentsUidList}) async{
    return await courseCollection.doc(courseId).update({
      'Students Name': studentsNameList,
      'Students Uid': studentsUidList
    });
  }

  List<Course> getAllCourses(){
    List<Course> courses = [];
    courseCollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        courses.add(Course(
          courseTitle: doc['Title'],
          courseCode: doc['Code'],
          instructorName: doc['Instructor Name'],
          academicYear: doc['Academic Year'],
          instructorUid: doc['Instructor Uid'],
          image: 'assets/images/placeholder.png',
        ));
      });
    });
    return courses;  
  }

  Future<List<Course>> getUserCourses() async {
    bool isTeacher = await this.isTeacher();
    List<Course> courses = [];
    if (isTeacher) {
      List<String> teachingCoursesId = [];
      DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
      teachingCoursesId = List<String>.from(doc['teachingCoursesId']);
      for (String courseId in teachingCoursesId) {
        DocumentSnapshot courseDoc = await courseCollection.doc(courseId).get();
        courses.add(Course(
          courseTitle: courseDoc['Title'],
          courseCode: courseDoc['Code'],
          instructorName: courseDoc['Instructor Name'],
          academicYear: courseDoc['Academic Year'],
          instructorUid: courseDoc['Instructor Uid'],
          image: courseDoc['image'],
        ));
      }
      this.teachingCoursesId = teachingCoursesId;
    } else {
      List<String> studyingCoursesId = [];
      DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
      studyingCoursesId = List<String>.from(doc['studyingCoursesId']);

      for (String courseId in studyingCoursesId) {
        DocumentSnapshot courseDoc = await courseCollection.doc(courseId).get();
        courses.add(Course(
          courseTitle: courseDoc['Title'],
          courseCode: courseDoc['Code'],
          instructorName: courseDoc['Instructor Name'],
          academicYear: courseDoc['Academic Year'],
          instructorUid: courseDoc['Instructor Uid'],
          image: courseDoc['image'],
        ));
      }
      this.studyingCoursesId = studyingCoursesId;
    }
    this.courses = courses;
    return courses;
  }

  Future<void> joinCourse(String CourseId) async {
    DocumentSnapshot doc = await courseCollection.doc(CourseId).get();
    List<String> studentsName = List<String>.from(doc['Students Name']);
    List<String> studentsUid = List<String>.from(doc['Students Uid']);
    studentsName.add(user.displayName ?? "");
    studentsUid.add(user.uid);
    List<String> studyingCoursesId = [];
    DocumentSnapshot userDoc = await usersCollection.doc(user.uid).get();
    studyingCoursesId = List<String>.from(userDoc['studyingCoursesId']);
    studyingCoursesId.add(CourseId);
    await usersCollection.doc(user.uid).update({'studyingCoursesId' : studyingCoursesId});
    return await courseCollection.doc(CourseId).update({
      'Students Name': studentsName,
      'Students Uid': studentsUid
    });
  }
}