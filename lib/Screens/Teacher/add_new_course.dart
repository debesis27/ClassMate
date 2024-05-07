
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/services/database.dart';
import 'package:ClassMate/Datasource/images_data.dart';

class AddNewCourse extends StatefulWidget {
  final User user;
  final Function onUpdate;

  const AddNewCourse({super.key, required this.user, required this.onUpdate});

  @override
  State<AddNewCourse> createState() => _AddNewCourseState();
}

class _AddNewCourseState extends State<AddNewCourse> {
  String courseTitle = '';
  String courseCode = '';
  String academicYear = '';
  int selectedImageIndex = 0;

  Future<void> saveInputs(User user) async {
    await Database(user: user).addCourse(Course(
      courseTitle: courseTitle,
      courseCode: courseCode,
      instructorName: user.displayName ?? "",
      academicYear: academicYear,
      instructorUid: user.uid,
      image: selectedImageIndex.toString(),
      courseReferenceId: ""
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor, // Use theme's primary color
        title: const Text('Add New Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTextField(
              label: 'Course Code',
              onChanged: (value) => setState(() => courseCode = value),
            ),
            _buildTextField(
              label: 'Course Title',
              onChanged: (value) => setState(() => courseTitle = value),
            ),
            _buildTextField(
              label: 'Academic Year',
              onChanged: (value) => setState(() => academicYear = value),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Image',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return _buildImageTile(index);
                },
              ),
            ),
            _buildSaveButton(),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required void Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter $label',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(int index) {
    bool isSelected = selectedImageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedImageIndex = index),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 2) : null,
        ),
        child: Opacity(
          opacity: isSelected ? 0.5 : 1,
          child: Image(
            image: images[index].image,
            fit: BoxFit.cover,
            width: 250,
            height: 80,
          ),
        ),
      ),
    );
  }


  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () async {
          await saveInputs(widget.user);
          await widget.onUpdate();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        child: const Text('Save'),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        child: const Text('Cancel'),
      ),
    );
  }
}
