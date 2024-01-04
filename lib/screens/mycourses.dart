import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/course.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'couresplayer.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<Course> courses = [];
  late TextEditingController _searchController;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchCourses();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCourses() async {
    final apiUrl = '$api/joinedcourses';
    try {
      var token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> fetchedCourses = json.decode(response.body);
        setState(() {
          courses = fetchedCourses.map((courseData) {
            return Course.fromJson(courseData);
          }).toList();
        });
      } else {
        print('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  List<Course> getFilteredCourses(String query) {
    return courses.where((course) {
      final name = course.name.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = getFilteredCourses(_searchController.text);
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5.0),
              SizedBox(
                width: 400.0,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    hintText: 'Search all courses',
                    prefixIcon: Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primary, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: secondary,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: filteredCourses.isEmpty
                    ? Center(
                        child: Text(
                          'No courses available',
                          style: TextStyle(fontSize: 18.0, color: secondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCourses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CoursePlayerScreen(
                                    courseId: filteredCourses[index].id,
                                  ),
                                ),
                              )
                            },
                            child: Card(
                              color: primary,
                              elevation: 4.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      filteredCourses[index].name,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: secondary,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Educator: ${filteredCourses[index].educator}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: secondary,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Duration: ${filteredCourses[index].duration} minutes',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
