
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, // Ensures use of the theme's primary color
        title: const Text(
          'Create Course',
          style: TextStyle(
            fontSize: 25, // Increase font size for better visibility
            fontWeight: FontWeight.bold, // Added font weight for better readability
          ),),
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
              child: TextField(
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                cursorWidth: 2,
                cursorColor: Colors.deepPurple,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Enter Course title',
                  label: const Text('Course Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (value) => setState(() {
                  courseTitle = value;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
              child: TextField(
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                cursorColor: Colors.deepPurple,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Enter Course code',
                  label: const Text('Course Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (value) => setState(() {
                  courseCode = value;
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
              child: TextField(
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                cursorColor: Colors.deepPurple,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: 'Enter Academic Year',
                  label: const Text('Academic Year', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                onChanged: (value) => setState(() {
                  academicYear = value;
                }),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Image',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
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
            const SizedBox(height: 20),  // Provide space before buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly for better distribution
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildSaveButton(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildCancelButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildTextField({required String label, required void Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter $label',
          label: Text('$label', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onChanged: onChanged,
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
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 50),
          backgroundColor: Colors.red, // A more vibrant color
          elevation: 5,
          shadowColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.white, width: 2)// Rounded corners
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Better padding for aesthetics
        ),
        child: const Text(
          'Create',
          style: TextStyle(
            fontSize: 20, // Larger text
            fontWeight: FontWeight.w600, // Bold text
            color: Colors.white, // White text for contrast
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white, width: 2)
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.grey
        ),
        child: const Text('Cancel', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black
        ),),
      ),
    );
  }
}
