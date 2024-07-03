import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tooth_tales/models/appointmentModel.dart';
import 'package:tooth_tales/screens/footer.dart';

class AppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String selectedSlot;

  AppointmentScreen({required this.doctorId, required this.selectedSlot});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late Map<String, dynamic> doctorData = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        setState(() {
          doctorData = doctorDoc.data() as Map<String, dynamic>;
        });
      } else {
        print('Doctor not found');
        // Handle the case where the doctor is not found
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  void _submitAppointment(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      String name = _nameController.text.trim();
      String age = _ageController.text.trim();
      String issue = _issueController.text.trim();

      final userId = FirebaseAuth.instance.currentUser?.uid; // Get user ID
      if (userId == null) {
        print('No user is currently logged in.');
        return;
      }

      try {
        // Create the appointment instance
        Appointment appointment = Appointment(
          doctorId: widget.doctorId,
          doctorName: doctorData['userName'],
          patientName: name,
          patientAge: age,
          patientIssue: issue,
          appointmentTime: widget.selectedSlot,
          timestamp: Timestamp.now(),
          userId: userId,
        );

        // Add appointment to Firestore
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('appointments')
            .add(appointment.toMap());

        // Get the document ID and update the appointment document with it
        String appointmentId = docRef.id;
        await docRef.update({'id': appointmentId});

        Navigator.pushReplacementNamed(context, '/schedule');
      } catch (e) {
        print('Error submitting appointment: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: doctorData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment with Dr. ${doctorData['userName']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Time: ${widget.selectedSlot}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Your Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _issueController,
                decoration: InputDecoration(
                  labelText: 'Concern',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your concern';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitAppointment(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      textStyle: TextStyle(
                        fontSize: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Book Appointment',
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FooterScreen(), // Ensure FooterScreen is properly defined
    );
  }
}
