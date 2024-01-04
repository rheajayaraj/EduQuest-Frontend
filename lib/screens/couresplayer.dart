import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/coursedetails.dart';
import 'package:eduquest/models/course.dart';

class CoursePlayerScreen extends StatefulWidget {
  final String courseId;
  CoursePlayerScreen({required this.courseId});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  late YoutubePlayerController _controller;
  late String courseId;
  CourseDetails courseDetails = CourseDetails(
      short_description: '',
      long_description: '',
      video_path: '',
      thumbnail_path: '',
      course_id:
          Course(category_id: '', id: '', name: '', duration: 0, educator: ''),
      id: '');

  void initState() {
    courseId = widget.courseId;
    fetchCourse();
    super.initState();
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
          _initializeController();
        });
      } else {
        print('Failed to fetch course: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching course: $error');
    }
  }

  void _initializeController() {
    final videoId = YoutubePlayer.convertUrlToId(courseDetails.video_path);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(autoPlay: true),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${courseDetails.course_id.name}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
          SizedBox(
            width: 400,
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
        ],
      ),
    );
  }
}
