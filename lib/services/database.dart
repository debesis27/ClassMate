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

  // Add student to a course manually by teacher
  Future<void> addStudentToCourse(String studentEntryNumber, String courseId) async {
    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;
    List<String> studentsNameList = courseData['Students Name'].cast<String>();
    List<String> studentsUidList = courseData['Students Uid'].cast<String>();
    if(studentsUidList.contains(studentEntryNumber)){
      return ;
    } // to avoid duplication of entries

    final studentDocumentSnapshot = await usersCollection.doc(studentEntryNumber).get();
    if(studentDocumentSnapshot.exists){
      final studentData = studentDocumentSnapshot.data() as Map<String, dynamic>;
      String studentName = studentData['Name'];
      List<String> studyingCoursesId = studentData['studyingCoursesId'].cast<String>();
      studyingCoursesId.add(courseId);
      await usersCollection.doc(studentEntryNumber).update({
        'studyingCoursesId': studyingCoursesId
      }); // updates the studyingCoursesId of the student in usersCollection

      studentsNameList.add(studentName);
      studentsUidList.add(studentEntryNumber);
      await courseCollection.doc(courseId).update({
        'Students Name': studentsNameList,
        'Students Uid' : studentsUidList
      }); // updates the studentsNameList and studentsUidList in the Course document
    }
  }

  // Remove student from a course manually by teacher
  Future<void> removeStudentFromCourse(String studentEntryNumber, String courseId) async {
    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;
    List<String> studentsNameList = courseData['Students Name'].cast<String>();
    List<String> studentsUidList = courseData['Students Uid'].cast<String>();
    if(!(studentsUidList.contains(studentEntryNumber))){
      return ;
    }

    final studentDocumentSnapshot = await usersCollection.doc(studentEntryNumber).get();
    if(studentDocumentSnapshot.exists){
      final studentData = studentDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = studentData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      await usersCollection.doc(studentEntryNumber).update({
        'studyingCoursesId': studyingCoursesId
      }); // updates the studyingCoursesId of the student in usersCollection

      int studentIndex = studentsUidList.indexOf(studentEntryNumber);
      studentsUidList.removeAt(studentIndex);
      studentsNameList.removeAt(studentIndex);
      await courseCollection.doc(courseId).update({
        'Students Name': studentsNameList,
        'Students Uid' : studentsUidList
      }); // removes the student's info from Students Name and Students Uid list of Course database
    }
  }

  // Teacher deletes a course from the database
  Future<void> deleteCourse(String courseId) async {
    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;

    List<String> studentsUidList = courseData['Students Uid'].cast<String>();
    for (String studentId in studentsUidList){
      final studentDocumentSnapshot = await usersCollection.doc(studentId).get();
      final studentData = studentDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = studentData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      await usersCollection.doc(studentId).update({
        'studyingCoursesId': studyingCoursesId
      }); // updates the studyingCoursesId of the student in usersCollection
    } // deletes the courseId from the studyingCoursesId of all the students in the Course

    final teacherDocumentSnapshot = await usersCollection.doc(user.uid).get();
    final teacherData = teacherDocumentSnapshot.data() as Map<String, dynamic>;
    List<String> teachingCoursesId = teacherData['teachingCoursesId'].cast<String>();
    teachingCoursesId.remove(courseId);
    await usersCollection.doc(user.uid).update({
      'teachingCoursesId': teachingCoursesId
    }); // removes the courseId from teacher's teachingCoursesId

    await courseCollection.doc(courseId).delete(); // deletes the entire course document from the courseCollection
  }

  // User leaves a course
  Future<void> studentLeaveCourse(String courseId) async {
    final userDocumentSnapshot = await usersCollection.doc(user.email!.substring(0, 11)).get();
    if(userDocumentSnapshot.exists) {
      final userData = userDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studyingCoursesId = userData['studyingCoursesId'].cast<String>();
      studyingCoursesId.remove(courseId);
      await usersCollection.doc(user.email!.substring(0, 11)).update({'studyingCoursesId' : studyingCoursesId});
    } // removes courseId from the user's studying course's id

    final courseDocumentSnapshot = await courseCollection.doc(courseId).get();
    if(courseDocumentSnapshot.exists){
      final courseData = courseDocumentSnapshot.data() as Map<String, dynamic>;
      List<String> studentsNameList = courseData['Students Name'].cast<String>();
      List<String> studentsUidList = courseData['Students Uid'].cast<String>();

      int studentIndex = studentsUidList.indexOf(user.email!.substring(0, 11));
      studentsUidList.removeAt(studentIndex);
      studentsNameList.removeAt(studentIndex);
      await courseCollection.doc(courseId).update({
        'Students Name': studentsNameList,
        'Students Uid' : studentsUidList
      }); // removes the student's info from Students Name and Students Uid list of Course database
    }
  }

  // Deletes the user from the database TODO: Modify delete from courses and courses he create
  Future<void> deleteUser() async {
    return await usersCollection.doc(user.uid).delete();
  }

}