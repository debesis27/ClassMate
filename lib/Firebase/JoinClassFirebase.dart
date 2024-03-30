import 'package:cloud_firestore/cloud_firestore.dart';


void joinClassFirebase(String studentId, String courseCollectionName, ){
  // need to add class info to user in the database
  print("hi");
  final db = FirebaseFirestore.instance;
  final student = <String, dynamic> {
    'studentId': studentId
  };
  db.collection(courseCollectionName).doc(studentId).set(student);
}