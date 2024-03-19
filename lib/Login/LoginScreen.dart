import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;


  @override
  void initState() {
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
        // print(_user!.uid);
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: _user!= null ? _logout() : _login(),
      );
  }

  Widget _login(){
    final db = FirebaseFirestore.instance;

    bool _teacher = false;
    String name = 'test user';
    String email = 'abcd@gmail.com';
    List<String> courses = ['MA517', 'MA518', 'MA519'];
    final user = <String, dynamic>{
      'name': name,
      'email': email,
      'courses': courses,
      'teacher': _teacher,
    };

    return ElevatedButton(
          onPressed: () async {
            await _auth.signInAnonymously();
            print(_user!.uid);
            final doc_ref = db.collection("users").doc(_user!.uid);
            doc_ref.set(user).then((value) => print('User Added')).catchError((error) => print('Failed to add user: $error'));
          },
          child: Text('Login'),
        );
  }

  Widget _logout(){
    return ElevatedButton(
      onPressed: () async {
        await _auth.signOut();
      },
      child: Text('Logout'),
    );
  }
}