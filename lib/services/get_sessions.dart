import 'package:cloud_firestore/cloud_firestore.dart';

List<String> getSessions(String courseId) {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  List<String> sessionIds = [];
  courseAttendanceReference.get().then((QuerySnapshot querySnapshot) {
    for (var doc in querySnapshot.docs) {
      sessionIds.add(doc.id);
    }
  });
  return sessionIds;
}