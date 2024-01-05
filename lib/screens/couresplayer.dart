import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/coursedetails.dart';
import 'package:eduquest/models/course.dart';
import 'package:video_player/video_player.dart';
import 'package:eduquest/theme/colours.dart';

class CoursePlayerScreen extends StatefulWidget {
  final String courseId;
  CoursePlayerScreen({required this.courseId});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late String courseId;
  CourseDetails courseDetails = CourseDetails(
      short_description: '',
      long_description: '',
      video_path: '',
      thumbnail_path: '',
      course_id:
          Course(category_id: '', id: '', name: '', duration: 0, educator: ''),
      id: '');

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
          _initializePlayer();
        });
      } else {
        print('Failed to fetch course: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching course: $error');
    }
  }

  void _initializePlayer() {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(courseDetails.video_path),
      )..initialize().then((_) {
          setState(() {});
        });
      _videoPlayerController.setLooping(true);
    } catch (error) {
      print('Error creating video player controller: $error');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
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
          _videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                )
              : Container(),
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
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
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
                      fontWeight: FontWeight.bold,
                      color: secondary,
                    ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: primary, // Change color if necessary
            onPressed: () {
              // Rewind by 10 seconds
              _videoPlayerController.seekTo(
                Duration(
                    seconds:
                        _videoPlayerController.value.position.inSeconds - 10),
              );
            },
            child: Icon(Icons.replay_10),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: primary, // Change color if necessary
            onPressed: () {
              // Forward by 10 seconds
              _videoPlayerController.seekTo(
                Duration(
                    seconds:
                        _videoPlayerController.value.position.inSeconds + 10),
              );
            },
            child: Icon(Icons.forward_10),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: primary, // Change color if necessary
            onPressed: () {
              setState(() {
                // pause
                if (_videoPlayerController.value.isPlaying) {
                  _videoPlayerController.pause();
                } else {
                  // play
                  _videoPlayerController.play();
                }
              });
            },
            // icon
            child: Icon(
              _videoPlayerController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}
