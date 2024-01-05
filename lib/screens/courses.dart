import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/models/course.dart';
import 'package:eduquest/screens/coursedetails.dart';
import 'package:provider/provider.dart';
import 'package:eduquest/provider/dataprovider.dart';

class CourseScreen extends StatefulWidget {
  final String category;
  CourseScreen({required this.category});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  List<Course> courses = [];
  late TextEditingController _searchController;
  late String category;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Course> getFilteredCourses(String query, List<Course> courses) {
    return courses.where((course) {
      final name = course.name.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    dataProvider.fetchCourses(category);
    final filteredCourses =
        getFilteredCourses(_searchController.text, dataProvider.courses);
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5.0),
              SizedBox(
                width: 400.0,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    hintText: 'Search all courses',
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
                    color: secondary,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCourses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailsScreen(
                              courseId: filteredCourses[index].id,
                            ),
                          ),
                        )
                      },
                      child: Card(
                        color: primary,
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filteredCourses[index].name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Duration: ${filteredCourses[index].duration} minutes',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
