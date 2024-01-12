import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/provider/dataprovider.dart';
import 'package:provider/provider.dart';
import 'package:eduquest/models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String planId;
  PaymentScreen({required this.amount, required this.planId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  late int amount;
  late String planID;
  late User currentUser;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    amount = widget.amount;
    planID = widget.planId;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> enroll() async {
    final apiUrl = '$api/joinplan/$planID';
    try {
      var token = await storage.read(key: 'token');
      final response = await http
          .post(Uri.parse(apiUrl), headers: {'Authorization': '$token'});
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Subscription Done', style: TextStyle(color: text)),
              content: Text('Happy Learning!', style: TextStyle(color: text)),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: primary),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                ),
              ],
            );
          },
        );
      } else {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Subscription Failed', style: TextStyle(color: text)),
              content: Text('$errorMessage', style: TextStyle(color: text)),
              backgroundColor: background,
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(color: primary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> payment(String? payment) async {
    try {
      var token = await storage.read(key: 'token');
      Map<String, dynamic> requestBody = {'payment_id': payment};
      await http.post(
        Uri.parse('$api/payment/$planID'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode(requestBody),
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    String? paymentId = response.paymentId;
    payment(paymentId);
    enroll();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Failed', style: TextStyle(color: text)),
          content: Text('Retry payment in a few minutes',
              style: TextStyle(color: text)),
          backgroundColor: background,
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_DcLTuxaja5mAwu',
      'amount': amount * 100,
      'name': 'EduQuest',
      'description': 'Subscription Purchase',
      'prefill': {
        'contact': '${currentUser.contact}',
        'email': '${currentUser.email}',
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error during payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    currentUser = dataProvider.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You will be paying',
                style: TextStyle(
                  fontSize: 20.0,
                  color: text,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Rs. $amount',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: _startPayment,
                icon: Icon(
                  Icons.payment,
                  color: secondary,
                ),
                label: Text(
                  'Pay Now',
                  style: TextStyle(color: background),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(primary),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
