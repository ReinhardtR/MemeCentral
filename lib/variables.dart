import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Styles
fontStyle(double size, [Color color, FontWeight fw = FontWeight.w700, FontStyle fs]) {
  return GoogleFonts.montserrat(
    fontSize: size,
    fontWeight: fw,
    fontStyle: fs,
    color: color,
  );
}

// Colors

// Collections
CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
CollectionReference contentCollection = FirebaseFirestore.instance.collection('content');

// Storage
StorageReference contentStorage = FirebaseStorage.instance.ref().child('content');
