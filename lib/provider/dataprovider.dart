import 'package:flutter/foundation.dart';
import 'package:eduquest/models/category.dart' as cat;
import 'package:eduquest/models/user.dart';
import 'package:eduquest/models/course.dart';
import 'package:eduquest/models/subscriptionplan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/theme/colours.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataProvider extends ChangeNotifier {
  User _currentUser = User(
    id: '',
    name: '',
    email: '',
    contact: '',
    gender: '',
    state: '',
    country: '',
    image: '',
  );
  late List<cat.Category> _categories = [];
  late List<Course> _courses = [];
  late List<SubscriptionPlan> _plans = [];
  final storage = const FlutterSecureStorage();

  User get currentUser => _currentUser;
  List<cat.Category> get categories => _categories;
  List<Course> get courses => _courses;
  List<SubscriptionPlan> get plans => _plans;

  Future<void> fetchUser() async {
    final apiUrl = '$api/user';
    try {
      var token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        final user = User.fromJson(json.decode(response.body));
        _currentUser = user;
      } else {
        print('Failed to fetch user: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user: $error');
    }
    notifyListeners();
  }

  Future<void> updateUser(Map<String, dynamic> requestBody) async {
    try {
      var token = await storage.read(key: 'token');
      final response = await http.patch(
        Uri.parse('$api/updateuser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        _currentUser = currentUser.copyWith(
            name: responseBody['name'],
            contact: responseBody['contact'],
            email: responseBody['email'],
            gender: responseBody['gender'],
            state: responseBody['state'],
            country: responseBody['country'],
            image: responseBody['image']);
        notifyListeners();
      } else {
        print('Failed to update user details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating user: $error');
    }
  }

  Future<void> fetchCategories() async {
    final apiUrl = '$api/categories';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedCategories = json.decode(response.body);
        _categories = fetchedCategories.map((categoryData) {
          return cat.Category.fromJson(categoryData);
        }).toList();
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
    notifyListeners();
  }

  Future<void> fetchCourses(String category) async {
    _courses.clear();
    final apiUrl = '$api/courses/$category';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedCourses = json.decode(response.body);
        _courses = fetchedCourses.map((courseData) {
          return Course.fromJson(courseData);
        }).toList();
      } else {
        print('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching courses: $error');
    }
    notifyListeners();
  }

  Future<void> fetchPlans() async {
    final apiUrl = '$api/subscriptionplans';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedPlans = json.decode(response.body);
        _plans = fetchedPlans.map((planData) {
          return SubscriptionPlan.fromJson(planData);
        }).toList();
      } else {
        print('Failed to fetch plans: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching plans: $error');
    }
    notifyListeners();
  }
}
