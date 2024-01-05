import 'package:eduquest/screens/paymentscreen.dart';
import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/models/subscriptionplan.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:eduquest/provider/dataprovider.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<SubscriptionPlan> plans = [];
  late TextEditingController _searchController;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> checkSubscription(int amount, String id) async {
    final apiUrl = '$api/checksubscription';
    try {
      var token = await storage.read(key: 'token');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '$token',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              amount: amount,
              planId: id,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Subscription already exists',
                style: TextStyle(color: secondary),
              ),
              content: Text(
                'You can subscribe to a new plan after the current subscription plan is over',
                style: TextStyle(color: secondary),
              ),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: secondary),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/myplan');
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {}
  }

  List<SubscriptionPlan> getFilteredPlans(
      String query, List<SubscriptionPlan> plans) {
    return plans.where((plan) {
      final name = plan.name.toLowerCase();
      final lowercaseQuery = query.toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    dataProvider.fetchPlans();
    final filteredPlans =
        getFilteredPlans(_searchController.text, dataProvider.plans);
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
                child: ListView.builder(
                  itemCount: filteredPlans.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: primary,
                      elevation: 4.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                            SizedBox(height: 8.0),
                            Text(
                              'Price: Rs.${filteredPlans[index].price}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: secondary,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll<Color>(
                                            secondary),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => checkSubscription(
                                      filteredPlans[index].price,
                                      filteredPlans[index].id),
                                  child: Text(
                                    'Subscribe',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
