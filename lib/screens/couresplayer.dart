import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eduquest/models/coursedetails.dart';
import 'package:eduquest/models/course.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eduquest/theme/colours.dart';

class CoursePlayerScreen extends StatefulWidget {
  final String courseId;

  CoursePlayerScreen({required this.courseId});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> {
  late String courseId;
  late bool isLoading = true;
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
          isLoading = false;
        });
      } else {
        print('Failed to fetch course: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching course: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    String htmlContent = '''
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Video Player</title>
          <style>
            body {
              margin: 0;
              padding: 0;
            }
            #videoPlayer {
              width: 100%;
              height: auto;
              controls {
                width: 100%; /* Set the width of controls to 100% */
                height: auto; /* Ensure controls maintain aspect ratio */
              }
            }
          </style>
        </head>
        <body style="background-color:#edf6f9;">
          <video id="videoPlayer" width="100%" height="auto" controls disablePictureInPicture="true" controlsList="nodownload">
            Your browser does not support the video tag.
          </video>
          <script>
            var videoPath = '${courseDetails.video_path}';
            document.getElementById('videoPlayer').src = videoPath;
          </script>
        </body>
      </html>
    ''';
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('${courseDetails.course_id.name}'),
        backgroundColor: background,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : courseDetails.video_path.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      child: InAppWebView(
                        initialData: InAppWebViewInitialData(data: htmlContent),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            useShouldOverrideUrlLoading: true,
                            mediaPlaybackRequiresUserGesture: false,
                            supportZoom: false,
                          ),
                          android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                          ),
                          ios: IOSInAppWebViewOptions(
                            allowsInlineMediaPlayback: true,
                          ),
                        ),
                        onLoadHttpError: (controller, url, code, message) {
                          print('HTTP error loading web content: $message');
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              fontWeight: FontWeight.bold,
                              color: text,
                            ),
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
                              fontWeight: FontWeight.bold,
                              color: text,
                            ),
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
                  ],
                )
              : Center(child: Text('No video available')),
    );
  }
}
