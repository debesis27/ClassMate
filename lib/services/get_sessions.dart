import 'package:ClassMate/Models/session_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<String> makeSession(String courseId) async {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  // Create a new document with Session Id with the attendance data
  DocumentReference sessionDoc = await courseAttendanceReference.add({});
  return sessionDoc.id;
}

Future<List<Session>> getSessions(String courseId) async {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  List<String> sessionIds = [];
  await courseAttendanceReference.get().then((QuerySnapshot querySnapshot) {
    for (var doc in querySnapshot.docs) {
      sessionIds.add(doc.id);
    }
  });
  List<Session> sessions = [];
  for (String sessionId in sessionIds) {
    DocumentSnapshot sessionDoc = await courseAttendanceReference.doc(sessionId).get();
    DateTime sessionDatetime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(sessionDoc['date'] + " " + sessionDoc['time']);
    sessions.add(Session(id: sessionId, datetime: sessionDatetime));
  }
  return sessions;
}