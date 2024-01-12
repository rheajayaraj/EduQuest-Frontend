import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/models/coursedetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/course.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';

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
  late bool isLoading = true;

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
          isLoading = false;
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
              title: Text('Course Enrolled', style: TextStyle(color: text)),
              content: Text('Congratulations! Happy Learning!',
                  style: TextStyle(color: text)),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: text),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
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
              title:
                  Text('Course Enroll Failed', style: TextStyle(color: text)),
              content: Text('$errorMessage', style: TextStyle(color: text)),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: secondary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (errorMessage == 'User not subscribed yet' ||
                    errorMessage == 'User subscription has expired')
                  TextButton(
                    child: Text(
                      'Subscribe',
                      style: TextStyle(color: text),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/plans');
                    },
                  )
                else
                  TextButton(
                    child: Text(
                      'Courses',
                      style: TextStyle(color: text),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/mycourses');
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
      body: isLoading
          ? _buildShimmerPlaceholder()
          : SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 400,
                        height: 170,
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
                                image: courseDetails.thumbnail_path.isNotEmpty
                                    ? NetworkImage(courseDetails.thumbnail_path)
                                    : AssetImage('assets/category.jpeg')
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseDetails.course_id.name,
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                color: text,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              courseDetails.short_description,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: text,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              courseDetails.long_description,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: text,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "Educator:",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: text,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              courseDetails.course_id.educator,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: text,
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "Duration:",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: text,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${(courseDetails.course_id.duration).toString()} minutes",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 360,
                        height: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(primary),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                              color: background,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
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

Widget _buildShimmerPlaceholder() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              width: 400,
              height: 170,
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
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerText(),
                  SizedBox(height: 8.0),
                  _buildShimmerText(),
                  SizedBox(height: 15.0),
                  _buildShimmerText(),
                  SizedBox(height: 15.0),
                  _buildShimmerText(),
                  _buildShimmerText(),
                  SizedBox(height: 15.0),
                  _buildShimmerText(),
                  _buildShimmerText(),
                ],
              ),
            ),
            SizedBox(
              width: 360,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: _buildShimmerText(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildShimmerText() {
  return SizedBox(
    width: double.infinity,
    height: 20.0,
    child: Container(
      color: Colors.grey,
      margin: EdgeInsets.symmetric(vertical: 4.0),
    ),
  );
}
