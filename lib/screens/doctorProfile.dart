import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'doctorHomePage.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _gender = 'Male';
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  File? _imageFile;
  List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',];
  Map<String, List<String>> _availability = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };
  @override
  void initState() {
    super.initState();
    _loadUserData();}
  Future<void> _loadUserData() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _userNameController.text = userData['userName'] ?? '';
        _specialityController.text = userData['speciality'] ?? '';
        _locationController.text = userData['location'] ?? '';
        _descriptionController.text = userData['description'] ?? '';
        _gender = userData['gender'] ?? 'Male';
        _imageUrl = userData['imageUrl'];
        _availability = userData['availability'] != null
            ? Map<String, List<String>>.from(userData['availability'])
            : {
          'Monday': [],
          'Tuesday': [],
          'Wednesday': [],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        };
      });
    }
  }

  Future<void> _updateProfile() async {
    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      // Upload the image file to Firebase Storage and get the URL
      imageUrl = await _uploadImage(_imageFile!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'userName': _userNameController.text,
        'speciality': _specialityController.text,
        'location': _locationController.text,
        'gender': _gender,
        'imageUrl': imageUrl,
        'description': _descriptionController.text,
        'availability': _availability,
      });

      _showCustomSnackBar(context, 'Profile updated successfully', Colors.green);
    } catch (e) {
      print('Error updating profile: $e');
      _showCustomSnackBar(context, 'Failed to update profile', Colors.red);
    }
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

  Future<void> _selectTimeSlots(BuildContext context, String day) async {
    List<String> selectedSlots = await showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> slots = [];
        List<String> amPmOptions = ['AM', 'PM'];

        return AlertDialog(
          title: Text('Select Time Slots for $day'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int hour = 1; hour <= 12; hour++)
                  for (String amPm in amPmOptions)
                    CheckboxListTile(
                      title: Text('$hour:00 $amPm'),
                      value: slots.contains('$hour:00 $amPm'),
                      onChanged: (checked) {
                        setState(() {
                          if (checked!) {
                            slots.add('$hour:00 $amPm');
                          } else {
                            slots.remove('$hour:00 $amPm');
                          }
                        });
                      },
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, slots);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (selectedSlots != null) {
      setState(() {
        _availability[day] = selectedSlots;
      });
    }
  }

  void _deleteTimeSlot(String day, String slot) {
    setState(() {
      _availability[day]?.remove(slot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _imageUrl != null
                        ? NetworkImage(_imageUrl!)
                        : AssetImage('assets/Images/avatar.png') as ImageProvider,
                    child: _imageFile == null && _imageUrl == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.white.withOpacity(0.7))
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _specialityController,
                decoration: InputDecoration(
                  labelText: 'Speciality',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
              SizedBox(height: 16),
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
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                maxLines: 4,
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
              SizedBox(height: 20),
              Text('Availability', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 10),
              Column(
                children: _days.map((day) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8.0,
                            children: _availability[day]!
                                .map((slot) => Chip(
                              label: Text(slot),
                              deleteIcon: Icon(Icons.close, size: 16),
                              onDeleted: () => _deleteTimeSlot(day, slot),
                            ))
                                .toList(),
                          ),
                          SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () => _selectTimeSlots(context, day),
                            child: Text('Select Time Slots'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateProfile();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorHomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  textStyle: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Update Profile', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
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
        // Handle dismiss action if needed
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
