import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class CSV {
  String courseId;
  CSV({required this.courseId});

/// Pick a CSV file and process its contents
  Future<void> pickAndProcessCSV() async {
    // Open file picker to select a CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Read the CSV file
      final input = file.openRead();
      List<List<dynamic>> fields = await input
          .transform(utf8.decoder) // Decode bytes to UTF8.
          .transform(CsvToListConverter()) // Convert CSV to List
          .toList();

      // Skip the header row and process each subsequent row
      if (fields.isNotEmpty) {
        List<dynamic> headers = fields.first; // This is the header row
        fields.removeAt(0); // Remove the header row

        // Process each row of the CSV file
        for (final row in fields) {
          if (row.isNotEmpty) {
            String documentName = row[0]; // First column is the doc name
            uploadMarksToFirestore(documentName, headers, row);
          }
        }
      }
    } else {
      // User canceled the picker
      print("No file selected");
    }
  }

  /// Uploads data to Firestore
  Future<bool> uploadMarksToFirestore(String documentName, List<dynamic> headers, List<dynamic> rowData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference courseDoc = firestore.collection('Courses').doc(courseId);
    CollectionReference marksCollection = courseDoc.collection('Marks');

    // Create a map to hold the data
    Map<String, dynamic> data = {};
    for (int i = 1; i < rowData.length; i++) {
      data[headers[i]] = rowData[i]; // Map each header to its corresponding value in the row
    }

    // Add data to Firestore under the specified document
    try {
      await marksCollection.doc(documentName).set(data);
      return true;  // Successfully updated Firestore
    } catch (error) {
      return false; // An error occurred
    }
  }
}
