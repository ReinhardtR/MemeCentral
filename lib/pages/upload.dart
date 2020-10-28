import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memecentral/pages/confirm.dart';
import 'package:memecentral/variables.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  pickFile(ImageSource src) async {
    Navigator.pop(context);
    final content = await ImagePicker().getImage(source: src);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmPage(File(content.path), content.path, src),
      ),
    );
  }

  showOptionsDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: () => pickFile(ImageSource.gallery),
              child: Text(
                "Gallery",
                style: fontStyle(20),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => pickFile(ImageSource.camera),
              child: Text(
                "Camera",
                style: fontStyle(20),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: fontStyle(20),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () => showOptionsDialog(),
        child: Center(
          child: Container(
            width: 190,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_rounded, size: 40),
                Text(
                  "Upload",
                  style: fontStyle(30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
