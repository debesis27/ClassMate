import 'package:cloud_firestore/cloud_firestore.dart';


String firebaseclasssetup(String courseCode, String courseTitle, String academicYear, String instructorId, String image){
  final db = FirebaseFirestore.instance;
  final course = <String, dynamic>{
    'code': courseCode,
    'title': courseTitle,
    'academicYear': academicYear,
    'instructor': instructorId,
    'image': image,
  };
  String collectionName = courseCode + " " + academicYear + " " + instructorId;
  db.collection(collectionName).doc('course_info').set(course);
  return collectionName;
}