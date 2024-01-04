import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduquest/models/subscriptionplan.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MySubscription extends StatefulWidget {
  const MySubscription({super.key});

  @override
  State<MySubscription> createState() => _MySubscriptionState();
}

class _MySubscriptionState extends State<MySubscription> {
  List<SubscriptionPlan> plans = [];
  late TextEditingController _searchController;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchCourses();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCourses() async {
    final apiUrl = '$api/joinedplans';
    try {
      var token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> fetchedPlans = json.decode(response.body);
        setState(() {
          plans = fetchedPlans.map((planData) {
            return SubscriptionPlan.fromJson(planData);
          }).toList();
        });
      } else {
        print('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching courses: $error');
    }
  }

  List<SubscriptionPlan> getFilteredPlans(String query) {
    return plans.where((plan) {
      final name = plan.name.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlans = getFilteredPlans(_searchController.text);
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
                    hintText: 'Search all plans',
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
                child: filteredPlans.isEmpty
                    ? Center(
                        child: Text(
                          'No subscriptions',
                          style: TextStyle(fontSize: 18.0, color: secondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPlans.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => {},
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
                                      filteredPlans[index].name,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: secondary,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Price: ${filteredPlans[index].price}',
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
