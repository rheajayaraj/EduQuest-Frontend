import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:eduquest/screens/splash.dart';
import 'package:eduquest/screens/signup.dart';
import 'package:eduquest/screens/login.dart';
import 'package:eduquest/screens/home.dart';
import 'package:eduquest/screens/profile.dart';
import 'package:eduquest/screens/forgotpassword.dart';
import 'package:eduquest/screens/verifycode.dart';
import 'package:eduquest/screens/mycourses.dart';
import 'package:eduquest/screens/mysubscription.dart';
import 'package:eduquest/screens/updateprofile.dart';
import 'package:eduquest/screens/couresplayer.dart';
import 'package:eduquest/provider/dataprovider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => DataProvider(),
    child: MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Loading(),
        '/signup': (context) => SignUp(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/mycourses': (context) => MyCoursesScreen(),
        '/myplan': (context) => MySubscription(),
        '/forgotpassword': (context) => ForgotPassword(),
        '/verifycode': (context) => VerifyCode(),
        '/profile': (context) => Profile(),
        '/updateprofile': (context) => UpdateProfileScreen(),
        '/player': (context) => CoursePlayerScreen(courseId: ''),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: secondary),
      ),
    ),
  ));
}
