import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/Screens/error_page.dart';
import 'package:ClassMate/Screens/register_page.dart';
import 'package:ClassMate/bluetooth/advertising.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user = FirebaseAuth.instance.currentUser;
  bool userIsRegistered = false;
  bool userIsTeacher = false;
  List<String> teachingCoursesId = [];
  List<String> studyingCoursesId = [];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null) {
      Database database = Database(user: _user!);
      // if the user is registered then check if the user is a teacher or a student
      // while the user is being checked, show a loading screen
      // if the user is not registered, then show the option to chose the role
      return FutureBuilder(
        future: database.isRegistered(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white, // Set the background color to white
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      elevation: 10, // Adds shadow to make the card stand out
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for the card
                      child: const Padding(
                        padding: EdgeInsets.all(20.0), // Padding inside the card
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Set the progress indicator color to blue
                            ),
                            SizedBox(height: 20), // Provide some space between the spinner and the text
                            Text(
                              'Loading, please wait...',
                              style: TextStyle(
                                color: Colors.black, // Set text color to black for contrast
                                fontSize: 16, // Set font size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

          }
          if (snapshot.hasError) {
            return buildErrorWidget(context, snapshot.error, () { setState(() {});});
          }
          if (snapshot.data == 1) {
            userIsRegistered = true;
            userIsTeacher = true;
            return TeacherHomePage(auth: _auth, user: _user!);
          } else if (snapshot.data == 2) {
            userIsRegistered = true;
            userIsTeacher = false;
            return StudentHomePage(auth: _auth, user: _user!,);
          } else {
            return ChoisePage(user: _user!, auth: _auth, database: database);
          }
        }
      );
      } else {
      userIsRegistered = false;
      return WelcomeScreen(auth: _auth);
    }
  }

  
  // uncomment this code to use the google sign in button in diffrent form simple
  // Widget _googleSignInButton() {
  //   return Center(
  //     child: AnimatedContainer(
  //       duration: Duration(milliseconds: 200),
  //       height: 50,
  //       width: MediaQuery.of(context).size.width * 0.55, // Makes it responsive
  //       decoration: BoxDecoration(
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.5),
  //             spreadRadius: 1,
  //             blurRadius: 3,
  //             offset: Offset(0, 1), // changes position of shadow
  //           ),
  //         ],
  //         borderRadius: BorderRadius.circular(8), // Adds rounded corners
  //       ),
  //       child: SignInButton(
  //         Buttons.google,
  //         text: "Sign up with Google",
  //         onPressed: _handleGoogleSignIn,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  //       ),
  //     ),
  //   );
  // }

  // void _handleGoogleSignIn(){
  //   try{
  //     GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
  //     _auth.signInWithProvider(googleAuthProvider);
  //   } catch(error){
  //     showDialog(
  //       context: context,
  //       builder: (context){
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: const Text('An error occurred while signing in with Google. Please try again later.'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: (){
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       }
  //     );
  //   }
  // }
}



class WelcomeScreen extends StatefulWidget {

  final FirebaseAuth auth;
  const WelcomeScreen({super.key, required this.auth});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacity;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    ));

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.elasticOut, // This curve provides a springy effect.
    ));

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _googleSignInButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      width: MediaQuery.of(context).size.width * 0.55,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SignInButton(
        Buttons.google,
        text: "Sign up with Google",
        onPressed: () {
          _handleGoogleSignIn();
          // print("Google Sign-In button pressed");
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: _opacity!,
              child: ScaleTransition(
                scale: _scale!,
                child: const Text(
                  'Welcome to Zoop',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            _googleSignInButton(),
          ],
        ),
      ),
    );
  }

  void _handleGoogleSignIn(){
    try{
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      widget.auth.signInWithProvider(googleAuthProvider);
    } catch(error){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while signing in with Google. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        }
      );
    }
  }
}
