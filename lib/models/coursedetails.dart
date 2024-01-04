import 'course.dart';

class CourseDetails {
  final String id;
  final String short_description;
  final String long_description;
  final String video_path;
  final String thumbnail_path;
  final Course course_id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_description': short_description,
      'long_description': long_description,
      'video_path': video_path,
      'thumbnail_path': thumbnail_path,
      'course_id': course_id.toJson(),
    };
  }

  CourseDetails(
      {required this.id,
      required this.short_description,
      required this.long_description,
      required this.video_path,
      required this.thumbnail_path,
      required this.course_id});

  factory CourseDetails.fromJson(Map<String, dynamic> json) {
    return CourseDetails(
      id: json['_id'] ?? '',
      short_description: json['short_description'] ?? '',
      long_description: json['long_description'] ?? '',
      video_path: json['video_path'] ?? '',
      thumbnail_path: json['thumbnail_path'] ?? '',
      course_id: Course.fromJson(json['course_id'] ?? {}),
    );
  }
}
