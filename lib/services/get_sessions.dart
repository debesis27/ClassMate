import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> makeSession(String courseId) async {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  // Create a new document with Session Id with the attendance data
  DocumentReference sessionDoc = await courseAttendanceReference.add({});
  return sessionDoc.id;
}

Future<List<String>> getSessions(String courseId) async {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  List<String> sessionIds = [];
  await courseAttendanceReference.get().then((QuerySnapshot querySnapshot) {
    for (var doc in querySnapshot.docs) {
      sessionIds.add(doc.id);
    }
  });
  return sessionIds;
}