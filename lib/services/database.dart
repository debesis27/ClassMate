import 'package:ClassMate/Models/course_info_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final User user;

  Database({required this.user});

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final CollectionReference courseCollection = FirebaseFirestore.instance.collection('Courses');

  Future<int> isRegistered() async {
    // return 0 if the user is not registered, 1 if the user is a teacher, 2 if the user is a student
    DocumentSnapshot doc1 = await usersCollection.doc(user.uid).get();
    DocumentSnapshot doc2 = await usersCollection.doc(user.email!.substring(0, 11)).get();
    int Teacher = 0;
    if (doc1.exists) {
      Teacher = 1;
    } else if (doc2.exists) {
      Teacher = 2;
    }
    return Teacher;
  }

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
    return await usersCollection.doc(user.email!.substring(0, 11)).set({
      'Name': user.displayName ?? "",
      'email': user.email!,
      'isTeacher': false,
      'teachingCoursesId' : [],
      'studyingCoursesId' : []
    });
  }

  // Adds a new course to the database and modifies the teachingCoursesId of the teacher
  Future<void> addCourse(Course course) async{
    DocumentReference courseRef =  await courseCollection.add({
      'Title': course.courseTitle,
      'Code': course.courseCode,
      'Academic Year': course.academicYear,
      'Instructor Name': course.instructorName,
      'Instructor Uid': course.instructorUid,
      'Students Name': [],
      'Students Uid': [],
      'image': course.image
    });
    String courseId = courseRef.id;
    DocumentSnapshot doc = await usersCollection.doc(user.uid).get();
    List<String> teachingCoursesId = List<String>.from(doc['teachingCoursesId']);
    teachingCoursesId.add(courseId);
    await usersCollection.doc(user.uid).update({'teachingCoursesId' : teachingCoursesId});
  }

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
    } else {
      List<String> studyingCoursesId = [];
      DocumentSnapshot doc = await usersCollection.doc(user.email!.substring(0, 11)).get();
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
    }
    return courses;
  }

  // Joins a user to a course and modifies the studyingCoursesId of the student
  Future<void> joinCourse(String courseId) async {
    DocumentSnapshot doc = await courseCollection.doc(courseId).get();
    List<String> studentsName = List<String>.from(doc['Students Name']);
    List<String> studentsUid = List<String>.from(doc['Students Uid']);
    if (studentsUid.contains(user.email!.substring(0, 11))) {
      return;
    }
    studentsName.add(user.displayName ?? "");
    studentsUid.add(user.email!.substring(0, 11));
    List<String> studyingCoursesId = [];
    DocumentSnapshot userDoc = await usersCollection.doc(user.email!.substring(0, 11)).get();
    studyingCoursesId = List<String>.from(userDoc['studyingCoursesId']);
    studyingCoursesId.add(courseId);
    await usersCollection.doc(user.email!.substring(0, 11)).update({'studyingCoursesId' : studyingCoursesId});
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
      await usersCollection.doc(user.uid).update({'studyingCoursesId' : studyingCoursesId});
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

  // Deletes the user from the database TODO: Modify delete from courses and courses he create
  Future<void> deleteUser() async {
    return await usersCollection.doc(user.uid).delete();
  }

  // Deletes a course from the database
  void deleteCourse(String courseId) async {
    //TODO: Delete course from the database
  }
}