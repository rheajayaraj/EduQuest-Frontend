class User {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String gender;
  final String state;
  final String country;
  final String image;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'gender': gender,
      'state': state,
      'country': country,
      'image': image
    };
  }

  User(
      {required this.id,
      required this.name,
      required this.contact,
      required this.email,
      required this.gender,
      required this.state,
      required this.country,
      required this.image});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
