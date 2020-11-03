import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memecentral/variables.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class CommentsPage extends StatefulWidget {
  final String id;
  CommentsPage(this.id);
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String uid;
  TextEditingController commentController = TextEditingController();
  int maxLength = 150;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
  }

  publishComment() async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();
    var allDocs = await contentCollection.doc(widget.id).collection('comments').get();
    contentCollection.doc(widget.id).collection('comments').doc('Comment ${allDocs.docs.length}').set({
      'username': userDoc.data()['username'],
      'uid': userDoc.data()['uid'],
      'profilePicture': userDoc.data()['profilePicture'],
      'comment': commentController.text,
      'likes': [],
      'time': DateTime.now(),
      'id': 'Comment ${allDocs.docs.length}',
    });
    commentController.clear();
    DocumentSnapshot doc = await contentCollection.doc(widget.id).get();
    contentCollection.doc(widget.id).update({
      'commentCount': doc.data()['commentCount'] + 1,
    });
  }

  likeComment(String id) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot doc = await contentCollection.doc(widget.id).collection('comments').doc(id).get();
    if (doc.data()['likes'].contains(uid)) {
      contentCollection.doc(widget.id).collection('comments').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      contentCollection.doc(widget.id).collection('comments').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: contentCollection.doc(widget.id).collection('comments').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot comment = snapshot.data.docs[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(comment.data()['profilePicture']),
                            ),
                            title: Text(
                              '${comment.data()['username']}',
                              style: fontStyle(16, Colors.grey[600], FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${comment.data()['comment']}',
                                  style: fontStyle(18, Colors.grey[900], FontWeight.w500),
                                ),
                                SizedBox(width: 10),
                                Text('${timeAgo.format(comment.data()['time'].toDate())}')
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => likeComment(comment.data()['id']),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 24,
                                    color: comment.data()['likes'].contains(uid) ? Colors.red : Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${comment.data()['likes'].length}',
                                  style: fontStyle(18, Colors.grey, FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                ),
              ),
              Column(
                children: [
                  Divider(
                    height: 0,
                    thickness: 1,
                    color: Colors.grey[400],
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    title: TextFormField(
                      controller: commentController,
                      maxLength: maxLength,
                      decoration: InputDecoration(
                        hintText: 'Add comment...',
                        hintStyle: fontStyle(20, Colors.grey[400], FontWeight.w400),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    trailing: OutlineButton(
                      onPressed: () => {
                        if (commentController.text.length <= maxLength && commentController.text.length > 0)
                          {
                            publishComment(),
                          },
                      },
                      borderSide: BorderSide.none,
                      child: Icon(Icons.send, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
