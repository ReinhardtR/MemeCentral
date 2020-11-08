import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memecentral/pages/comments.dart';
import 'package:memecentral/variables.dart';

class ContentPage extends StatefulWidget {
  final QuerySnapshot contentList;
  final int contentIndex;
  ContentPage(this.contentList, this.contentIndex);

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  Stream stream;
  String uid;
  bool isFollowing;

  initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    stream = contentCollection.snapshots();
  }

  likePost(String id) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot doc = await contentCollection.doc(id).get();
    if (doc.data()['likes'].contains(uid)) {
      contentCollection.doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      contentCollection.doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  sharePost(String content, String id) async {
    var request = await HttpClient().getUrl(Uri.parse(content));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('MemeCentral', 'Image.jpeg', bytes, 'image/jpeg');
    DocumentSnapshot doc = await contentCollection.doc(id).get();
    contentCollection.doc(id).update({
      'shareCount': doc.data()['shareCount'] + 1,
    });
  }

  followState(String postUid) async {
    DocumentSnapshot doc = await userCollection.doc(uid).collection('following').doc(postUid).get();
    if (doc.exists) {
      setState(() {
        isFollowing = true;
      });
      return true;
    } else {
      setState(() {
        isFollowing = false;
      });
      return false;
    }
  }

  followUser(String postUid) async {
    if (await followState(postUid)) {
      userCollection.doc(postUid).collection('followers').doc(uid).delete();
      userCollection.doc(uid).collection('following').doc(postUid).delete();
      setState(() {
        isFollowing = false;
      });
    } else {
      userCollection.doc(postUid).collection('followers').doc(uid).set({});
      userCollection.doc(uid).collection('following').doc(postUid).set({});
      setState(() {
        isFollowing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          body: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return PageView.builder(
                itemCount: widget.contentList == null ? snapshot.data.docs.length : widget.contentList.docs.length,
                controller: PageController(
                  initialPage: widget.contentIndex == null ? 0 : widget.contentIndex,
                  viewportFraction: 1,
                ),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot content = snapshot.data.docs[index];
                  followState(content.data()['uid']);
                  return Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        // Top UI
                        Container(
                          alignment: Alignment.bottomLeft,
                          height: 64,
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.cover,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: NetworkImage(
                                      content.data()['profilePicture'],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content.data()['username'],
                                      style: fontStyle(16, Colors.white, FontWeight.bold),
                                    ),
                                    Text(
                                      content.data()['caption'],
                                      style: fontStyle(16, Colors.white, FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              VerticalDivider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    content.data()['category'],
                                    style: fontStyle(14, Colors.white, FontWeight.normal, FontStyle.italic),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                          thickness: 1,
                          height: 0,
                        ),
                        // Content
                        Expanded(
                          child: Center(
                            child: Image.network(
                              content.data()['contentURL'],
                            ),
                          ),
                        ),
                        // Bottom UI
                        Divider(
                          color: Colors.white,
                          thickness: 1,
                          height: 0,
                        ),
                        // Post Stats
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(left: 8, right: 8),
                          color: Colors.black,
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () => followUser(content.data()['uid']),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isFollowing == true
                                              ? Icons.check_circle_rounded
                                              : Icons.highlight_off_rounded,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          isFollowing == true ? "Unfollow" : "Follow",
                                          style: fontStyle(14, Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 1,
                                  width: 32,
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => likePost(content.data()['id']),
                                            child: Icon(Icons.favorite,
                                                size: 30,
                                                color:
                                                    content.data()['likes'].contains(uid) ? Colors.red : Colors.white),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            content.data()['likes'].length.toString(),
                                            style: fontStyle(18, Colors.white),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CommentsPage(
                                                  content.data()['id'],
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.comment_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            content.data()['commentCount'].toString(),
                                            style: fontStyle(20, Colors.white),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => sharePost(content.data()['contentURL'], content.data()['id']),
                                            child: Icon(
                                              Icons.share_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            content.data()['shareCount'].toString(),
                                            style: fontStyle(20, Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
