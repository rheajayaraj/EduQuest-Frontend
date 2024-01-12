import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_online_rounded,
                  color: primary,
                  size: 100.0,
                ),
                Text(
                  'EduQuest',
                  style: TextStyle(
                      color: text, fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                      color: text, fontSize: 14.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 30.0,
                ),
                SizedBox(
                  width: 300.0,
                  height: 60.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(primary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/');
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                          color: background,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
