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

  initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    stream = contentCollection.snapshots();
  }

  buildProfile(String url) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: (60 / 2) - (50 / 2),
            child: Container(
              width: 50,
              height: 50,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    url,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: (60 / 2) - (20 / 2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
                      return Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              height: 70,
                              color: Colors.black,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  buildProfile(content.data()['profilePicture']),
                                  InkWell(
                                    child: Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.comment_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.share_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Content
                            Center(
                              child: Image.network(
                                content.data()['contentURL'],
                                width: size.width,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Column(
                              children: [
                                // Top Section
                                Container(
                                  height: 100,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Following",
                                        style: fontStyle(17, Colors.white, FontWeight.bold),
                                      ),
                                      SizedBox(width: 7.5),
                                      Text(
                                        "|",
                                        style: fontStyle(17, Colors.white, FontWeight.bold),
                                      ),
                                      SizedBox(width: 7.5),
                                      Text(
                                        "Recommended",
                                        style: fontStyle(17, Colors.white, FontWeight.bold),
                                      ),
                                      SizedBox(width: 7.5),
                                      Text(
                                        "|",
                                        style: fontStyle(17, Colors.white, FontWeight.bold),
                                      ),
                                      SizedBox(width: 7.5),
                                      Text(
                                        "Trending",
                                        style: fontStyle(17, Colors.white, FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),

                                // Bottom Section
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Left Side
                                      Expanded(
                                        child: Container(
                                          height: 70,
                                          padding: EdgeInsets.only(left: 20),
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                content.data()['username'],
                                                style: fontStyle(16, Colors.white, FontWeight.normal),
                                              ),
                                              Text(
                                                content.data()['caption'],
                                                style: fontStyle(16, Colors.white, FontWeight.normal),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    content.data()['category'],
                                                    style: fontStyle(
                                                        14, Colors.white, FontWeight.normal, FontStyle.italic),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Right Side
                                      Container(
                                        width: 100,
                                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            buildProfile(content.data()['profilePicture']),
                                            // Likes
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () => likePost(content.data()['id']),
                                                  child: Icon(
                                                    Icons.favorite,
                                                    size: 30,
                                                    color: content.data()['likes'].contains(uid)
                                                        ? Colors.red
                                                        : Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  content.data()['likes'].length.toString(),
                                                  style: fontStyle(14, Colors.white),
                                                ),
                                              ],
                                            ),
                                            // Comments
                                            Column(
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
                                                    Icons.comment,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  content.data()['commentCount'].toString(),
                                                  style: fontStyle(14, Colors.white),
                                                ),
                                              ],
                                            ),
                                            // Share
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () =>
                                                      sharePost(content.data()['contentURL'], content.data()['id']),
                                                  child: Icon(
                                                    Icons.reply,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 7),
                                                Text(
                                                  content.data()['shareCount'].toString(),
                                                  style: fontStyle(14, Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              }),
        ),
      ),
    );
  }
}
