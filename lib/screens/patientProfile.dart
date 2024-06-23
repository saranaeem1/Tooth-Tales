import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _userNameController.text = userData['userName'] ?? '';
        _dobController.text = userData['dateOfBirth'] ?? '';
        _gender = userData['gender'] ?? 'Male';
        _imageUrl = userData['imageUrl'];
      });
    }
  }

  Future<void> _updateProfile() async {
    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      // Upload the image file to Firebase Storage and get the URL
      imageUrl = await _uploadImage(_imageFile!);
    }

    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'userName': _userNameController.text,
      'dateOfBirth': _dobController.text,
      'gender': _gender,
      'imageUrl': imageUrl,
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$userId.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : _imageUrl != null
                    ? NetworkImage(_imageUrl!)
                    : AssetImage('assets/Images/avatar.png') as ImageProvider,
              ),
            ),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'YYYY-MM-DD',
              ),
              keyboardType: TextInputType.datetime,
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                child: Text(label),
                value: label,
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
