import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/Screens/register_page.dart';
import 'package:ClassMate/bluetooth/advertising.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').snapshots(),
          builder: (context, snapshots){
            if(snapshots.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if(snapshots.hasError){
              return Center(
                child: Text('${snapshots.error}'),
              );
            } else{
              List<DocumentSnapshot<Object?>> userDocuments = snapshots.data!.docs;
              for(int i = 0; i < userDocuments.length; i++){
                if(userDocuments[i].id == _user!.uid){
                  userIsRegistered = true;
                  userIsTeacher = userDocuments[i]['isTeacher'];
                  if(userIsTeacher){
                    teachingCoursesId = userDocuments[i]['teachingCoursesId'].cast<String>();
                  }else{
                    studyingCoursesId = userDocuments[i]['studyingCoursesId'].cast<String>();
                  }
                  break;
                }
              }

              if(userIsRegistered){
                if(userIsTeacher){
                  return TeacherHomePage(auth: _auth, user: _user!,);
                } else{
                  // TODO: Remove this later
                  String entryNumber = _user!.email!.substring(0, 11);
                  startAdvertising(id: entryNumber);
                  return StudentHomePage(auth: _auth, user: _user!,);
                }
              } else{
                return RegisterPage(auth: _auth, user: _user!);
              }
            }
          });
    } else {
      userIsRegistered = false;
      return Scaffold(
        appBar: AppBar(
          title: const Text('ZooP - Zoned Out of Proxy'),
          backgroundColor: Colors.blue,
        ),
        body: _googleSignInButton(),
      );
    }
  }

  Widget _googleSignInButton(){
    return Center(
      child: SizedBox(
        height: 45,
        child: SignInButton(
          Buttons.google,
          text: "Sign up with Google",
          onPressed: _handleGoogleSignIn,
        ),
      ),
    );
  }

  void _handleGoogleSignIn(){
    try{
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(googleAuthProvider);
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
