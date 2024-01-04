import 'package:eduquest/screens/courses.dart';
import 'package:eduquest/screens/subscriptionplans.dart';
import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/category.dart';
import 'package:eduquest/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Category> categories = [];
  late TextEditingController _searchController;
  final storage = const FlutterSecureStorage();
  User currentUser = User(
      id: '',
      name: '',
      email: '',
      contact: '',
      gender: '',
      state: '',
      country: '',
      image: '');

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategories();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final apiUrl = '$api/categories';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> fetchedCategories = json.decode(response.body);
        setState(() {
          categories = fetchedCategories.map((categoryData) {
            return Category.fromJson(categoryData);
          }).toList();
        });
      } else {
        print('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  Future<void> fetchData() async {
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
        setState(() {
          currentUser = user;
        });
      } else {
        print('Failed to fetch course: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching course: $error');
    }
  }

  List<Category> getFilteredCategories(String query) {
    return categories.where((category) {
      final name = category.name.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = currentUser.image;
    print(currentUser);
    print(currentUser.name);
    print(currentUser.image);
    final filteredCategories = getFilteredCategories(_searchController.text);
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5.0),
              Row(
                children: [
                  SizedBox(
                    width: 290.0,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        hintText: 'Search all categories',
                        prefixIcon: Icon(Icons.search),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: secondary),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  PopupMenuButton<String>(
                    color: background,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: ListTile(
                          iconColor: secondary,
                          textColor: secondary,
                          leading: Icon(Icons.person),
                          title: Text('My Profile'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'courses',
                        child: ListTile(
                          iconColor: secondary,
                          textColor: secondary,
                          leading: Icon(Icons.book),
                          title: Text('My Courses'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'plan',
                        child: ListTile(
                          iconColor: secondary,
                          textColor: secondary,
                          leading: Icon(Icons.list),
                          title: Text('My Subscription'),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile');
                      } else if (value == 'courses') {
                        Navigator.pushNamed(context, '/mycourses');
                      } else if (value == 'plan') {
                        Navigator.pushNamed(context, '/myplan');
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: imagePath.isNotEmpty ? null : secondary,
                      backgroundImage:
                          imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
                      radius: 35.0,
                      child: imagePath.isEmpty
                          ? Text(
                              currentUser.name.isNotEmpty
                                  ? currentUser.name[0]
                                  : '',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseScreen(
                                category: filteredCategories[index].id,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4.0,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FadeInImage.assetNetwork(
                                placeholder: 'assets/category.jpeg',
                                image: filteredCategories[index].thumbnail_path,
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/category.jpeg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                              Center(
                                child: Text(
                                  filteredCategories[index].name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400,
                                    color: background,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionScreen(),
                    ),
                  );
                },
                child: SizedBox(
                  height: 110,
                  width: 400,
                  child: Card(
                    color: primary,
                    child: Center(
                      child: Text(
                        "Subscription Plans",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w400,
                          color: background,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
