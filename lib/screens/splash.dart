import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:io';

class Loading extends StatefulWidget {
  const Loading({Key? key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  late bool hasInternet = false;
  final storage = const FlutterSecureStorage();

  Future<bool> checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  void checkJWT() async {
    String? jwt = await storage.read(key: 'token');
    if (jwt != null) {
      Navigator.pushNamed(
        context,
        '/home',
      );
    } else {
      Navigator.pushNamed(
        context,
        '/login',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Perform the internet connectivity check
    checkInternetConnectivity().then((result) {
      setState(() {
        hasInternet = result;
        // If internet is available, proceed to check JWT
        if (hasInternet) {
          checkJWT();
        } else {
          Navigator.pushNamed(context, '/no-internet');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_online_rounded,
              color: background,
              size: 100.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Empower Learning with EduQuest',
              style: TextStyle(
                fontSize: 20.0,
                color: background,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            SpinKitWaveSpinner(
              color: background,
              size: 50.0,
            )
          ],
        ),
      ),
    );
  }
}
