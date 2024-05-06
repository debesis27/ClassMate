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


  // Checks if the user is a teacher
  Future<bool> isTeacher() async {
    final User user = this.user;
    DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
    if (!doc.exists) {
      return false;
    }
    return doc['isTeacher'];
  }

  // Sets up the teacher's collection for a new user
  void setTeachersCollection() async {
    return await usersCollection.doc(user.uid).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': true,
      'teachingCoursesId': [],
      'studyingCoursesId' : []
    });
  }

  // Sets up the student's collection for a new user
  void setStudentsCollection() async{
    return await usersCollection.doc(user.uid).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': false,
      'teachingCoursesId' : [],
      'studyingCoursesId' : []
    });
  }

  // Deletes the user from the database
  Future<void> deleteUser(){
    return usersCollection.doc(user.uid).delete();
  }

  // Updates the teacher's courses
  void updateTeacherCourses(List<String> coursesIdList) async{
    return await usersCollection.doc(user.uid).update({'teachingCoursesId' : coursesIdList});
  }

  // Updates the student's courses
  void updateStudentCourses(List<String> courseIdList) async{
    return await usersCollection.doc(user.uid).update({'studyingCoursesId' : courseIdList});
  }

  // Adds a new course to the database
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

  // Deletes a course from the database
  void deleteCourse(String courseId) async {
    // TODO: Check if this works
    await courseCollection.doc(courseId).delete();
  }

  // this function is used to get the course details from the database
  // // Adds a user to a course
  // void addUserToCourse({required String courseId, required List<String> studentsNameList, required List<String> studentsUidList}) async{
  //   return await courseCollection.doc(courseId).update({
  //     'Students Name': studentsNameList,
  //     'Students Uid': studentsUidList
  //   });
  // }

  // // Retrieves all courses from the database
  // List<Course> getAllCourses(){
  //   List<Course> courses = [];
  //   courseCollection.get().then((QuerySnapshot querySnapshot) {
  //     for (var doc in querySnapshot.docs) {
  //       courses.add(Course(
  //         courseTitle: doc['Title'],
  //         courseCode: doc['Code'],
  //         instructorName: doc['Instructor Name'],
  //         academicYear: doc['Academic Year'],
  //         instructorUid: doc['Instructor Uid'],
  //         image: doc['image'],
  //         courseReferenceId: doc.id
  //       ));
  //     }
  //   });
  //   return courses;  
  // }

  // Retrieves the courses of the current user
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
          courseReferenceId: courseId
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
          courseReferenceId: courseId
        ));
      }
      this.studyingCoursesId = studyingCoursesId;
    }
    this.courses = courses;
    return courses;
  }

  // Joins a user to a course
  Future<void> joinCourse(String courseId) async {
    DocumentReference courseRef = courseCollection.doc(courseId);
    DocumentSnapshot doc = await courseCollection.doc(courseId).get();
    List<String> studentsName = List<String>.from(doc['Students Name']);
    List<String> studentsUid = List<String>.from(doc['Students Uid']);
    studentsName.add(user.displayName ?? "");
    studentsUid.add(user.uid);
    List<String> studyingCoursesId = [];
    DocumentSnapshot userDoc = await usersCollection.doc(user.uid).get();
    studyingCoursesId = List<String>.from(userDoc['studyingCoursesId']);
    studyingCoursesId.add(courseId);
    await usersCollection.doc(user.uid).update({'studyingCoursesId' : studyingCoursesId});
    courseRef.collection('Attendance').doc(user.uid).set({
      'Name': user.displayName,
      'Uid': user.uid,
    });
    return await courseCollection.doc(courseId).update({
      'Students Name': studentsName,
      'Students Uid': studentsUid
    });
  }

  // User leaves a course
  void studentLeaveCourse(String courseId) async {
    final userDocumentSnapshot = await usersCollection.doc(user.uid).get();
    if(userDocumentSnapshot.exists) {
      final userData = userDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = userData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      return updateStudentCourses(studyingCoursesId);
    }

    //TODO remove student name and uid from corresponding course document
  }

  // Add student to a course manually by teacher
  Future<void> addStudentToCourse(String studentEntryNumber) async {
    //TODO: Add student to a course
  }

  // Remove student from a course manually by teacher
  Future<void> removeStudentFromCourse(String studentEntryNumber) async {
    //TODO: add functionality
  }

  // Gets Course Id
  Future<String> getCourseId(String courseCode, String academicYear, String instructorUid) async {
    QuerySnapshot querySnapshot = await courseCollection.where('Code', isEqualTo: courseCode).where('Academic Year', isEqualTo: academicYear).where('Instructor Uid', isEqualTo: instructorUid).get();
    return querySnapshot.docs[0].id;
  }
}
