import 'package:flutter/material.dart';
import 'package:eduquest/theme/colours.dart';
import 'package:http/http.dart' as http;
import 'package:eduquest/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:eduquest/provider/dataprovider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User currentUser = User(
      id: '',
      name: '',
      email: '',
      contact: '',
      gender: '',
      state: '',
      country: '',
      image: '');
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete', style: TextStyle(color: text)),
          content: Text('Are you sure you want to delete your account?'),
          backgroundColor: background,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: secondary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',
                  style: TextStyle(color: text, fontWeight: FontWeight.w700)),
              onPressed: () async {
                var token = await storage.read(key: 'token');
                final response = await http.delete(
                  Uri.parse('$api/deleteuser'),
                  headers: {
                    'Authorization': '$token',
                  },
                );
                if (response.statusCode == 200) {
                  Navigator.pushReplacementNamed(context, '/signup');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout', style: TextStyle(color: text)),
          content: Text('Are you sure you want to log out?'),
          backgroundColor: background,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: secondary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout',
                  style: TextStyle(color: text, fontWeight: FontWeight.w700)),
              onPressed: () async {
                try {
                  await storage.delete(key: 'token');
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (error) {
                  print('Error logging out: $error');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    String imagePath = dataProvider.currentUser.image;
    final currentUser = dataProvider.currentUser;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Profile Details'),
        backgroundColor: background,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10.0),
                CircleAvatar(
                  backgroundColor: imagePath.isNotEmpty ? null : secondary,
                  backgroundImage:
                      imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
                  radius: 80.0,
                  child: imagePath.isEmpty
                      ? Text(
                          currentUser.name.isNotEmpty
                              ? currentUser.name[0]
                              : '',
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: text,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        currentUser.name,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w400,
                          color: text,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        currentUser.contact,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: text,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        currentUser.email,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: text,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: 400,
              child: Card(
                color: background,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Other Details:',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: text,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Gender: ${currentUser.gender}",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: text,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "State: ${currentUser.state}",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: text,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Country: ${currentUser.country}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: 360.0,
              height: 60.0,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(background),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: accent,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/updateprofile',
                    arguments: currentUser,
                  );
                },
                child: Text(
                  'Update Profile',
                  style: TextStyle(
                    color: text,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: 360.0,
              height: 60.0,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(background),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: accent,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  _confirmDelete();
                },
                child: Text(
                  'Delete Profile',
                  style: TextStyle(
                    color: text,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: 360.0,
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
                  _logout();
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: background,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
