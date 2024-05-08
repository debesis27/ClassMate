import 'package:flutter/material.dart';

Widget buildErrorWidget(BuildContext context, dynamic error, VoidCallback refreshFunction) {
  return Container(
    color: Colors.white, // Set the background color to white
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error_outline, color: Colors.red, size: 40), // Add an icon for visual feedback
          SizedBox(height: 20),
          Text(
            "Oops! Connection error occurred.",
            style: TextStyle(color: Colors.black54, fontSize: 16), // Styling the text
          ),
          SizedBox(height: 10),
          Text(
            "$error", // Display the error passed to the function
            style: TextStyle(color: Colors.redAccent, fontSize: 14), // Error details in a more subtle tone
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: refreshFunction, // Use the passed function for the button
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button color
              foregroundColor: Colors.white, // Text color
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    ),
  );
}
