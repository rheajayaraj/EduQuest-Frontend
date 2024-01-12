import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/models/course.dart';
import 'package:eduquest/screens/coursedetails.dart';
import 'package:provider/provider.dart';
import 'package:eduquest/provider/dataprovider.dart';
import 'package:shimmer/shimmer.dart';

class CourseScreen extends StatefulWidget {
  final String category;
  CourseScreen({required this.category});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late TextEditingController _searchController;
  late String category;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    _searchController = TextEditingController();
    fetchData();
  }

  void fetchData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.fetchCourses(category);
    setState(() {});
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
    final filteredCourses =
        getFilteredCourses(_searchController.text, dataProvider.courses);

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      body: category.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
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
                          color: text,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCourses.isEmpty
                            ? 2
                            : filteredCourses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return filteredCourses.isEmpty
                              ? buildShimmerCourseCard()
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseDetailsScreen(
                                          courseId: filteredCourses[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: background,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            filteredCourses[index].name,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: text,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            'Duration: ${filteredCourses[index].duration} minutes',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: text,
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

  Widget buildShimmerCourseCard() {
    return SizedBox(
      width: double.infinity,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          color: Colors.white,
          elevation: 4.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
