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

  const AccountPage({super.key, required this.auth, required this.user, required this.allCourses, required this.isTeacher});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = widget.auth;
    final User user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontSize: 24),),
        backgroundColor: Colors.blue,
      ),
      drawer: MyNavigationDrawer(
        isTeacher: widget.isTeacher,
        auth: auth,
        user: user,
        database: Database(user: user),
        allCourses: widget.allCourses,
        currentPage: "Account",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: NetworkImage(user.photoURL!), fit: BoxFit.cover),
                    )),
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
              Text(
                widget.isTeacher ? "Teacher" : "Student",
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                      elevation: 10,
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: (){
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
                                  Database(user: user).deleteUser();
                                  auth.signOut();
                                  Navigator.pop(context, true);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
                                },
                                child: const Text('Delete Account'),
                              ),
                            ],
                          );
                        
                        },
                      );
                    },
                    child: const Text('Delete Account', style: TextStyle(fontSize: 18, color: Colors.white),)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Colors.blueAccent,
                  child: const Text('Log Out', style: TextStyle(fontSize: 18, color: Colors.yellow),),
                  onPressed: (){
                    auth.signOut();
                    Navigator.pop(context, true);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
                  }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
