import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/models/coursedetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/course.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  CourseDetailsScreen({required this.courseId});

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  CourseDetails courseDetails = CourseDetails(
      short_description: '',
      long_description: '',
      video_path: '',
      thumbnail_path: '',
      course_id:
          Course(category_id: '', id: '', name: '', duration: 0, educator: ''),
      id: '');
  late String courseId;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    courseId = widget.courseId;
    fetchCourse();
  }

  Future<void> fetchCourse() async {
    final apiUrl = '$api/coursecontent/$courseId';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final fetchedCourse =
            CourseDetails.fromJson(json.decode(response.body));
        setState(() {
          courseDetails = fetchedCourse;
        });
      } else {
        print('Failed to fetch course: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching course: $error');
    }
  }

  Future<void> enroll(String courseID) async {
    final apiUrl = '$api/joincourse/$courseID';
    try {
      var token = await storage.read(key: 'token');
      final response = await http
          .post(Uri.parse(apiUrl), headers: {'Authorization': '$token'});
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  Text('Course Enrolled', style: TextStyle(color: secondary)),
              content: Text('Congratulations! Happy Learning!',
                  style: TextStyle(color: secondary)),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: secondary),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/mycourses');
                  },
                ),
              ],
            );
          },
        );
      } else {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Course Enroll Failed',
                  style: TextStyle(color: secondary)),
              content:
                  Text('$errorMessage', style: TextStyle(color: secondary)),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: secondary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error fetching course: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  width: 400,
                  child: Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: AssetImage('assets/category.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseDetails.course_id.name,
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                color: secondary,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              courseDetails.short_description,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: Card(
                    color: primary,
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseDetails.long_description,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: secondary,
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            "Educator:",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: secondary,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            courseDetails.course_id.educator,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: secondary,
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            "Duration:",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: secondary,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${(courseDetails.course_id.duration).toString()} minutes",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(primary),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          enroll(courseDetails.course_id.id);
                        },
                        child: Text(
                          'Enroll',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
