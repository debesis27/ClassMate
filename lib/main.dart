import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ClassMate/Login/LoginScreen.dart';
import 'package:ClassMate/bluetooth/advertising.dart';
import 'package:ClassMate/bluetooth/ble_scan.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  startAdvertising();
  // PermissionsService().requestPermission();
}

class Course {
  final String name;
  final String title;
  final String academicYear;
  final String instructor;
  final String image;

  Course({
    required this.name,
    required this.title,
    required this.academicYear,
    required this.instructor,
    required this.image,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Classes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
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
      drawer: Drawer(
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
                  'Attendance App',
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
              },
            ),
            ListTile(
              title: const Text('Classes'),
              onTap: () {
                // Handle Classes button tap
                Navigator.push(context, MaterialPageRoute( builder: (context) => MyHomePage(),),);
              },
            ),
            ListTile(
              title: const Text('Login'),
              onTap: () {
                // Handle Login button tap
                Navigator.push(context, MaterialPageRoute( builder: (context) => LoginScreen(),),);
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
                        builder: (context) =>
                            CourseDetailScreen(course: course),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: ListView.builder(
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
              ));
        },
      ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.name),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Attendance'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Ble_Body(),
            ),
            Center(
              child: Text('Stats for ${course.name}'),
            ),
          ],
        ),
      ),
    );
  }
}
