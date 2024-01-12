import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduquest/screens/courses.dart';
import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/models/category.dart';
import 'package:eduquest/provider/dataprovider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    _searchController.dispose();
    super.dispose();
  }

  List<Category> getFilteredCategories(
      String query, List<Category> categories) {
    return categories.where((category) {
      final name = category.name.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    dataProvider.fetchUser();
    dataProvider.fetchCategories();
    String imagePath = dataProvider.currentUser.image;
    final filteredCategories =
        getFilteredCategories(_searchController.text, dataProvider.categories);
    final currentUser = dataProvider.currentUser;
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
                      width: 302.0,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search all categories',
                          prefixIcon: Icon(
                            Icons.search,
                            color: primary,
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
                    SizedBox(
                      width: 10.0,
                    ),
                    PopupMenuButton<String>(
                      color: background,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: ListTile(
                            iconColor: primary,
                            textColor: text,
                            leading: Icon(Icons.person),
                            title: Text('My Profile'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'courses',
                          child: ListTile(
                            iconColor: primary,
                            textColor: text,
                            leading: Icon(Icons.book),
                            title: Text('My Courses'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'plan',
                          child: ListTile(
                            iconColor: primary,
                            textColor: text,
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
                        backgroundColor:
                            imagePath.isNotEmpty ? null : secondary,
                        backgroundImage: imagePath.isNotEmpty
                            ? NetworkImage(imagePath)
                            : null,
                        radius: 32.0,
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
                  child: dataProvider.categories.isEmpty
                      ? _buildShimmerPlaceholder()
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                              child: SizedBox(
                                width: 120,
                                height: 240,
                                child: Card(
                                  color: background,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/category.jpeg',
                                              image: filteredCategories[index]
                                                  .thumbnail_path,
                                              fit: BoxFit.cover,
                                              imageErrorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/category.jpeg',
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 4.0),
                                        child: Text(
                                          filteredCategories[index].name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w400,
                                            color: text,
                                          ),
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
        ));
  }
}

Widget _buildShimmerPlaceholder() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: 9,
      itemBuilder: (BuildContext context, int index) {
        return SizedBox(
          width: 120,
          height: 240,
          child: Card(
            elevation: 0.0,
            color: Colors.white,
          ),
        );
      },
    ),
  );
}
