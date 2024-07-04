import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/reusable_widgets/reusable_widget.dart';
import 'package:tooth_tales/screens/signup.dart';
import 'package:tooth_tales/screens/homepage.dart';
import 'package:tooth_tales/screens/doctorHomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.cyan,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: [
                Image.asset(
                  "assets/Images/login.png",
                  width: 250,
                ),
                Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50),
                reusableTextField("Enter Email", Icons.person_outline, false,
                    _emailTextController),
                SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),
                SizedBox(height: 20),
                signInSignUpButton(context, true, _signInUser),
                signUpOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      String userId = userCredential.user!.uid;
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        print('User document data: ${userDoc.data()}');
        bool isDoctor = userDoc.get('isDoctor');
        _showCustomSnackBar(context, 'Login successful!', Colors.green);
        if (isDoctor) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => DoctorHomePage()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      } else {
        print('User document does not exist in Firestore');
      }
    } catch (error) {
      print("Error signing in: $error");
      _showCustomSnackBar(context, 'Error signing in: $error', Colors.red);
    }
  }

  void _showCustomSnackBar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          // Some code to undo the change if necessary.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Row signUpOption(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
        },
        child: const Text(
          " Sign Up",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
