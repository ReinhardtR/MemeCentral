import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memecentral/pages/content.dart';
import 'package:memecentral/variables.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  ProfilePage(this.uid);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool dataRecieved = false;

  String username;
  String profilePicture;
  int likes = 0;
  Future userContent;
  String onlineUser;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    // Content
    userContent = contentCollection.where('uid', isEqualTo: widget.uid).get();

    // User Data
    DocumentSnapshot userDoc = await userCollection.doc(widget.uid).get();
    username = userDoc.data()['username'];
    profilePicture = userDoc.data()['profilePicture'];

    var documents = await userContent;
    for (var item in documents.docs) {
      likes = item.data()['likes'].length + likes;
    }

    setState(() {
      dataRecieved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataRecieved == false
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(profilePicture),
                      ),
                      SizedBox(height: 20),
                      Text(
                        username,
                        style: fontStyle(24, Colors.grey[900]),
                      ),
                      SizedBox(height: 20),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "78",
                                  style: fontStyle(20, Colors.grey[900], FontWeight.w500),
                                ),
                                Text(
                                  "Followers",
                                  style: fontStyle(16, Colors.grey[600], FontWeight.w500),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color: Colors.grey[300],
                              thickness: 1,
                              width: 50,
                            ),
                            Column(
                              children: [
                                Text(
                                  likes.toString(),
                                  style: fontStyle(20, Colors.grey[900], FontWeight.w500),
                                ),
                                Text(
                                  "Likes",
                                  style: fontStyle(16, Colors.grey[600], FontWeight.w500),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color: Colors.grey[300],
                              thickness: 1,
                              width: 50,
                            ),
                            Column(
                              children: [
                                Text(
                                  "34",
                                  style: fontStyle(20, Colors.grey[900], FontWeight.w500),
                                ),
                                Text(
                                  "Following",
                                  style: fontStyle(16, Colors.grey[600], FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () => {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          width: MediaQuery.of(context).size.width / 2,
                          height: 40,
                          child: Center(
                            child: Text(
                              "Edit profile",
                              style: fontStyle(20, Colors.white, FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.only(left: 30, right: 30),
                        child: Text(
                          "Placeholder description text... Long walks on the beach, drinking water, love that O2, drake turn it into O3!",
                          style: fontStyle(16, Colors.grey[800], FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(
                        thickness: 1,
                        color: Colors.grey[900],
                        height: 0,
                      ),
                      FutureBuilder(
                        future: userContent,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return Container(
                            padding: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(color: Colors.grey[900]),
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                              ),
                              itemBuilder: (context, index) {
                                DocumentSnapshot content = snapshot.data.docs[index];
                                return InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContentPage(snapshot.data, index),
                                    ),
                                  ),
                                  child: Container(
                                    child: Image(
                                      image: NetworkImage(content.data()['contentURL']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
