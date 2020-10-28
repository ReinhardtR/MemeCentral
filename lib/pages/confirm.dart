import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memecentral/variables.dart';

class ConfirmPage extends StatefulWidget {
  final File content;
  final String contentPath;
  final ImageSource contentSource;

  ConfirmPage(this.content, this.contentPath, this.contentSource);
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  File contentFile;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      contentFile = widget.content;
    });
  }

  @override
  void dispose() {
    contentFile = null;
    super.dispose();
  }

  uploadFileToStorage(String id) async {
    StorageUploadTask storageUploadTask = contentStorage.child(id).putFile(contentFile);
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;
    String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  uploadVideo() async {
    setState(() {
      isUploading = true;
    });
    try {
      var firebaseUserUID = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot userDoc = await userCollection.doc(firebaseUserUID).get();
      var allDocs = await contentCollection.get();
      String contentID = 'Content ${allDocs.docs.length}';
      String file = await uploadFileToStorage(contentID);

      contentCollection.doc(contentID).set({
        'username': userDoc.data()['username'],
        'uid': firebaseUserUID,
        'profilePicture': userDoc.data()['profilePicture'],
        'id': contentID,
        'likes': [],
        'commentCount': 0,
        'shareCount': 0,
        'title': titleController.text,
        'caption': captionController.text,
        'category': categoryController.text,
        'contentURL': file,
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUploading == true
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Uploading...",
                    style: fontStyle(20),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Image
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: contentFile == null ? Text("No file selected.") : Image.file(contentFile),
                  ),
                  SizedBox(height: 20),
                  // Title Input
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Title",
                        labelStyle: fontStyle(20),
                        prefixIcon: Icon(
                          Icons.text_fields,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Caption Input
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: TextField(
                      controller: captionController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Caption",
                        labelStyle: fontStyle(20),
                        prefixIcon: Icon(Icons.closed_caption),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Category Input
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: TextField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Category",
                        labelStyle: fontStyle(20),
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Publish Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () => uploadVideo(),
                        color: Colors.lightBlue,
                        child: Text(
                          "Publish",
                          style: fontStyle(20, Colors.white),
                        ),
                      ),
                      SizedBox(width: 20),
                      RaisedButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.orange,
                        child: Text(
                          "New file",
                          style: fontStyle(20, Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
