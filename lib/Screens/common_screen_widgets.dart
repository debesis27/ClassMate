import 'package:ClassMate/Models/course_info_model.dart';
import 'package:ClassMate/Screens/Student/home_screen_student.dart';
import 'package:ClassMate/Screens/Teacher/home_screen_teacher.dart';
import 'package:ClassMate/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Student/course_details.dart';

class AllCoursesList extends StatelessWidget {
  const AllCoursesList({
    super.key,
    required this.allCourses,
  });

  final List<Course> allCourses;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allCourses.length,
      itemBuilder: (context, index) {
        Course course = allCourses[index];
        return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(course: course),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(course.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${course.courseCode} - ${course.courseTitle}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AY: ${course.academicYear}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      course.instructorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
        );
      },
    );
  }
}

class MyNavigationDrawer extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  final bool isTeacher;
  final List<Course> allCourses;

  const MyNavigationDrawer({
    super.key,
    required this.isTeacher,
    required this.auth,
    required this.user,
    required this.allCourses,
  });

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    Widget homePage;
    final FirebaseAuth auth = widget.auth;
    final User user = widget.user;
    
    if(widget.isTeacher) {
      homePage = TeacherHomePage(auth: auth, user: user,);
    } else {
      homePage = StudentHomePage(auth: auth, user: user,);
    }
    
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 100, // Adjust the height as needed
            child: DrawerHeader(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: Colors.blue,
              ),
              child: Text(
                'ClassMate',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Account'),
            onTap: () {
              // Handle Account button tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AccountPage(auth: auth, user: user)));
            },
          ),
          ListTile(
            title: const Text('Classes'),
            onTap: () {
              // Handle Classes button tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => homePage));
            },
          ),
          ListTile(
            title: const Text('Tasks'),
            onTap: () {
              // Handle Tasks button tap
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'All Classes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: widget.allCourses.map((course) {
              return ListTile(
                title: Text(course.courseCode),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}




class AccountPage extends StatefulWidget {
  final FirebaseAuth auth;
  final User user;
  const AccountPage({super.key, required this.auth, required this.user});

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
        backgroundColor: Colors.orange,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: Colors.redAccent,
              child: const Text('Log Out', style: TextStyle(fontSize: 18, color: Colors.yellow),),
              onPressed: (){
                auth.signOut();
                Navigator.pop(context, true);
              }),
          )
        ],
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
                clipBehavior: Clip.antiAlias,
                  height: 100,
                  width: 100,
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
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(),
                    elevation: 10,
                    backgroundColor: Colors.red
                  ),
                  onPressed: (){
                    Database(user: user).deleteUser();
                    auth.signOut();
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete Account', style: TextStyle(fontSize: 18, color: Colors.white),)),
            )
          ],
        ),
      ),
    );
  }
}

