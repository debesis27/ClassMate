import 'package:ClassMate/Login/login_screen.dart';
import 'package:ClassMate/Models/course_info_model.dart';
import 'package:flutter/material.dart';
import 'Student/course_details.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Course> allCourses = [
    Course(
      name: 'MA517',
      title: 'Distributed Algorithms',
      academicYear: '2023-24',
      instructor: 'Kaushik Mondal',
      image: 'assets/mathematics.jpg',
    ),
    Course(
      name: 'MA302',
      title: 'Optimization Techniques',
      academicYear: '2023-24',
      instructor: 'Arti Pandey',
      image: 'assets/physics.jpg',
    ),
    Course(
      name: 'HS301',
      title: 'Operation Management',
      academicYear: '2023-24',
      instructor: 'Ravi Kumar',
      image: 'assets/chemistry.jpg',
    ),
    Course(
      name: 'CS503',
      title: 'Machine Learning',
      academicYear: '2023-24',
      instructor: 'Shashi Shekhar Jha',
      image: 'assets/biology.jpg',
    ),
    Course(
      name: 'CS204',
      title: 'Computer Architecture',
      academicYear: '2023-24',
      instructor: 'Neeraj Goel',
      image: 'assets/history.jpg',
    ),
    Course(
      name: 'CP301',
      title: 'DEP',
      academicYear: '2023-24',
      instructor: 'Arti Pandey',
      image: 'assets/english.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Classes'),
        backgroundColor: Colors.blue,
      ),
      drawer: NavigationDrawer(allCourses: allCourses),
      body: AllCoursesList(allCourses: allCourses),
    );
  }
}

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
                          '${course.name} - ${course.title}',
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
                      course.instructor,
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

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({
    super.key,
    required this.allCourses,
  });

  final List<Course> allCourses;

  @override
  Widget build(BuildContext context) {
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
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
          ListTile(
            title: const Text('Classes'),
            onTap: () {
              // Handle Classes button tap
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
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
            children: allCourses.map((course) {
              return ListTile(
                title: Text(course.name),
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
