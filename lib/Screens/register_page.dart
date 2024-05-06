import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  const RegisterPage({super.key, required this.auth, required this.user});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    final User user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ZooP',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                      image: DecorationImage(image: NetworkImage(user.photoURL!), fit: BoxFit.cover))),
            ),
            Text(
              user.displayName ?? "--",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            Text(
              user.email!,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Text(
                'Register on ZooP as- ',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.brown,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: OutlinedButton(
                      onPressed: () {
                        Database(user: user).setTeachersCollection();
                      },
                      child: const Text(
                        'Teacher',
                        style: TextStyle(fontSize: 21),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: OutlinedButton(
                      onPressed: () {
                        Database(user: user).setStudentsCollection();
                      },
                      child: const Text(
                        'Student',
                        style: TextStyle(fontSize: 21),
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
