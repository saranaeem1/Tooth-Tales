import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tooth_tales/start.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyCfwbX0BpGrCXB8o9WSVaPSS9kF5R482Ec',
        appId: '1:94725667875:android:cb3acf569488c8401ec596',
        messagingSenderId: '94725667875',
        projectId: 'tooth-tales',
        storageBucket: 'tooth-tales.appspot.com',)
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}
