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
import 'package:eduquest/screens/subscriptionplans.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduquest/screens/nointernet.dart';

void main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: "EduQuest_key",
        channelName: "EduQuest",
        channelDescription: "Notifications for your learning",
      )
    ],
    debug: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(
    ChangeNotifierProvider(
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
          '/plans': (context) => SubscriptionScreen(),
          '/no-internet': (context) => NoInternetScreen()
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: secondary),
        ),
      ),
    ),
  );
}

Future<void> initNotifications() async {
  checkLastAppUsage();
}

Future<void> checkLastAppUsage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int lastUsageTimestamp = prefs.getInt('lastUsageTimestamp') ?? 0;
  final DateTime lastUsage = DateTime.fromMillisecondsSinceEpoch(
      lastUsageTimestamp != 0 ? lastUsageTimestamp : 0);
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(lastUsage);
  if (difference.inDays > 0) {
    await showNotification();
  }
  prefs.setInt('lastUsageTimestamp', now.millisecondsSinceEpoch);
}

Future<void> showNotification() async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'EduQuest_key',
      title: 'Missing You😭',
      body: 'It has been a day since you last used our app.',
    ),
  );
}
