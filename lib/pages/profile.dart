import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isFollowing = false;

  String username;
  String profilePicture;
  int likes = 0;
  int followers = 0;
  int following = 0;
  Future userContent;

  String onlineUser;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    // Get Online User
    onlineUser = FirebaseAuth.instance.currentUser.uid;

    // Get Followers and Following
    var followersDocument = await userCollection.doc(widget.uid).collection('followers').get();
    var followingDocument = await userCollection.doc(widget.uid).collection('following').get();
    followers = followersDocument.docs.length;
    following = followingDocument.docs.length;

    // Get Follow State
    userCollection.doc(widget.uid).collection('followers').doc(onlineUser).get().then(
      (document) {
        if (document.exists) {
          setState(() {
            isFollowing = true;
          });
        } else {
          setState(() {
            isFollowing = false;
          });
        }
      },
    );

    // Get Content
    userContent = contentCollection.where('uid', isEqualTo: widget.uid).get();

    // Get User Data
    DocumentSnapshot userDoc = await userCollection.doc(widget.uid).get();
    username = userDoc.data()['username'];
    profilePicture = userDoc.data()['profilePicture'];

    // Get Likes
    var documents = await userContent;
    for (var item in documents.docs) {
      likes = item.data()['likes'].length + likes;
    }

    setState(() {
      dataRecieved = true;
    });
  }

  followUser() async {
    var document = await userCollection.doc(widget.uid).collection('followers').doc(onlineUser).get();

    if (!document.exists) {
      userCollection.doc(widget.uid).collection('followers').doc(onlineUser).set({});
      userCollection.doc(onlineUser).collection('following').doc(widget.uid).set({});
      setState(() {
        isFollowing = true;
        followers++;
      });
    } else {
      userCollection.doc(widget.uid).collection('followers').doc(onlineUser).delete();
      userCollection.doc(onlineUser).collection('following').doc(widget.uid).delete();
      setState(() {
        isFollowing = false;
        followers--;
      });
    }
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
                                  followers.toString(),
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
                                  following.toString(),
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
                      onlineUser == widget.uid
                          ? InkWell(
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
                            )
                          : InkWell(
                              onTap: () => followUser(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                width: MediaQuery.of(context).size.width / 2,
                                height: 40,
                                child: Center(
                                  child: Text(
                                    isFollowing == false ? "Follow" : "Unfollow",
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
                          } else if (snapshot.data.docs.length == 0) {
                            return Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(color: Colors.grey[900]),
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  child: Text(
                                    "$username haven't uploaded any memes.",
                                    style: fontStyle(20, Colors.white, FontWeight.w800),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }
                          print(snapshot.data.docs);
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
