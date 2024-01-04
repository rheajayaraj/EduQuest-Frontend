class Course {
  final String id;
  final String name;
  final int duration;
  final String educator;
  final String category_id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'educator': educator,
      'category_id': category_id
    };
  }

  Course(
      {required this.id,
      required this.name,
      required this.duration,
      required this.educator,
      required this.category_id});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      educator: json['educator'] ?? '',
      category_id: json['category_id'] ?? '',
    );
  }
}
