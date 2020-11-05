import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/content.dart';
import 'pages/discover.dart';
import 'pages/upload.dart';
import 'pages/inbox.dart';
import 'pages/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List pageOptions = [
    ContentPage(null, null),
    DiscoverPage(),
    UploadPage(),
    InboxPage(),
    ProfilePage(FirebaseAuth.instance.currentUser.uid),
  ];

  int page = 0;

  customIcon() {
    return Container(
      width: 45,
      height: 30,
      margin: EdgeInsets.only(bottom: 5),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            width: 38,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 38,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Center(
            child: Container(
              height: double.infinity,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, size: 26, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageOptions[page],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
        currentIndex: page,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 35),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 35),
            label: "Discover",
          ),
          BottomNavigationBarItem(
            icon: customIcon(),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, size: 35),
            label: "Inbox",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 35),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
