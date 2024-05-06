import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Screens/common_screen_widgets.dart';
import 'package:ClassMate/Screens/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ClassMate/services/database.dart';

class AccountPage extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  final List<Course> allCourses;
  final bool isTeacher;

  const AccountPage(
      {super.key,
      required this.auth,
      required this.user,
      required this.allCourses,
      required this.isTeacher});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Account',
            style: TextStyle(fontSize: 24),
          ),
          backgroundColor: Colors.blue,
        ),
        drawer: MyNavigationDrawer(
          isTeacher: widget.isTeacher,
          auth: widget.auth,
          user: widget.user,
          database: Database(user: widget.user),
          allCourses: widget.allCourses,
          currentPage: "Account",
        ),
        body: Column(
          children: [
            AccountCard(user: widget.user, isTeacher: widget.isTeacher),
            const SizedBox(height: 10),
            AccountPersonalInfo(user: widget.user),
            const SizedBox(height: 15),
            AccountLogoutCard(auth: widget.auth, context: context),
            AccountDeleteCard(auth: widget.auth, context: context),
          ],
        )
    );
  }
}

class AccountCard extends StatelessWidget {
  final User user;
  final bool isTeacher;

  const AccountCard({super.key, required this.user, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  clipBehavior: Clip.antiAlias,
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(user.photoURL!), fit: BoxFit.cover),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName == null || user.displayName!.trim().isEmpty
                        ? "Shivam Maske"
                        : user.displayName!,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    user.email!,
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    isTeacher ? "Teacher" : "Student",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class AccountPersonalInfo extends StatelessWidget {
  final User user;

  const AccountPersonalInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap:() {
                          // TODO: Implement the functionality to change the profile picture
                        },
                        child: const Text(
                          'Change Profile Picture',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const Divider(height: 26, thickness: 1),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement the functionality to change the name
                        },
                        child: const Text(
                          'Change Name',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const Divider(height: 26, thickness: 1),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement the functionality to change the email
                        },
                        child: const Text(
                          'Change Email',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountLogoutCard extends StatelessWidget {
  final FirebaseAuth auth;
  final BuildContext context;

  const AccountLogoutCard({super.key, required this.auth, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    auth.signOut();
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  },
                  child: const Text('Log Out'),
                ),
              ],
            );
          },
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Card(
            elevation: 3,
            // color: const Color.fromARGB(255, 255, 29, 29),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccountDeleteCard extends StatelessWidget {
  final FirebaseAuth auth;
  final BuildContext context;

  const AccountDeleteCard({super.key, required this.auth, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text('Are you sure you want to delete your account?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    auth.signOut();
                    Navigator.pop(context, true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()));
                  },
                  child: const Text('Delete Account'),
                ),
              ],
            );
          },
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Card(
            elevation: 3,
            // color: const Color.fromARGB(255, 255, 29, 29),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Delete Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
