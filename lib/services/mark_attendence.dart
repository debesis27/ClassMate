import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For date formatting

Future<Map<String, dynamic>> markAttendance(String courseId, {String sessionId = "", int timeout = 10}) async {
  print('Marking attendance for session $sessionId in course $courseId');
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');
  
  // Get the list of all students in the course
  DocumentSnapshot courseDoc = await FirebaseFirestore.instance.collection('Courses').doc(courseId).get();
  List<String> allStudesnts = List<String>.from(courseDoc['Students Uid']);
  
  // reading the current data that is present in the session
  DocumentSnapshot sessionDoc = await courseAttendanceReference.doc(sessionId).get();
  Map<String, dynamic> attendanceData = {};
  if (sessionDoc.exists) {
    attendanceData = sessionDoc.data() as Map<String, dynamic>;
    attendanceData['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    attendanceData['time'] = DateFormat('HH:mm:ss').format(DateTime.now());
  } else {
    // Initialize the attendance data with all students absent
    attendanceData['date'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    attendanceData['time'] = DateFormat('HH:mm:ss').format(DateTime.now());
    for (String studentId in allStudesnts) {
      attendanceData[studentId] = false;
    }
  }
  
  // Mark the students present
  List<String> studentsToMarkPresent = await scanDevices(timeout: timeout);
  for (String studentId in studentsToMarkPresent) {
    attendanceData[studentId] = true;
  }

  // Create a new document with Session Id with the attendance data
  if (sessionId == "") {
    await courseAttendanceReference.doc().set(attendanceData);
    return attendanceData;
  }
  await courseAttendanceReference.doc(sessionId).set(attendanceData);
  return attendanceData;
}