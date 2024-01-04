class Category {
  final String id;
  final String name;
  final String thumbnail_path;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_path': thumbnail_path,
    };
  }

  Category(
      {required this.id, required this.name, required this.thumbnail_path});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      thumbnail_path: json['thumbnail_path'] ?? '',
    );
  }
}
