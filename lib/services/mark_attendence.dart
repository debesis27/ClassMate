import 'package:ClassMate/Models/session_info.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For date formatting

Future<String> markAttendance(String courseId, {String sessionId = "", int timeout = 10}) async {
  // Reference to the attendance subcollection for the specified course
  CollectionReference courseAttendanceReference = FirebaseFirestore.instance.collection('Courses').doc(courseId).collection('Attendance');

  //Setting the session id-
  // print('yaha tak aagya');
  await courseAttendanceReference.get().then((QuerySnapshot querySnapshot){
    int numberOfSessions = querySnapshot.size;
    sessionId = (numberOfSessions+1).toString();
    // print('creation $sessionId');
  });
  // print('yaha bhi aagya');
  
  // Get the list of all students in the course
  DocumentSnapshot courseDoc = await FirebaseFirestore.instance.collection('Courses').doc(courseId).get();
  List<String> allStudesnts = List<String>.from(courseDoc['Students Uid']);


  Map<String, dynamic> attendanceData = {};
  // reading the current data that is present in the session
  
  DocumentSnapshot sessionDoc = await courseAttendanceReference.doc(sessionId).get();
  print(sessionId);
  if(sessionDoc.exists){
    print(sessionDoc);
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
    print(attendanceData);
  }
  
  // Mark the students present
  List<String> studentsToMarkPresent = await scanDevices(timeout: timeout);
  for (String studentId in studentsToMarkPresent) {
    if (allStudesnts.contains(studentId)) {
      attendanceData[studentId] = true;
    }
  }
  // Create a new document with Session Id with the attendance data
  if (sessionId == "") {
    await courseAttendanceReference.add(attendanceData).then((value) => sessionId = value.id);
    return sessionId;
  }
  await courseAttendanceReference.doc(sessionId).set(attendanceData);
  print('sab hogya');
  return sessionId;
}