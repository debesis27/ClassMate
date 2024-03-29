import 'package:cloud_firestore/cloud_firestore.dart';


void joinClassFirebase(String studentId, String courseCollectionName, ){
  final db = FirebaseFirestore.instance;
  final student = <String, dynamic>{
    'studentId': studentId,
  };
  db.collection(courseCollectionName).doc(studentId).set(student);
}