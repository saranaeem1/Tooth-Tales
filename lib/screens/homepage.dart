import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'patientProfile.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> imgSrc = [
    "assets/Images/toothimg9.png",
    "assets/Images/toothimg7.png",
    "assets/Images/toothimg4.png",
    "assets/Images/toothimg10.png",
    "assets/Images/toothimg6.png",
    "assets/Images/toothimg8.png",
  ];
  final List<String> titles = [
    "Personalized Plan",
    "Brushing Timer",
    "Dental Products",
    "Dental Health Articles",
    "Dental Friendly Diet",
    "Daily Tips",
  ];

  String userName = '';
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('userName');
            imageUrl = userDoc.get('imageUrl');
          });
        } else {
          print('User document does not exist');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey, // Assign key to Scaffold
      appBar: AppBar(
        title: Text('Home Page'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open drawer using key
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyan,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : AssetImage('assets/Images/avatar.png') as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.cyan,
        height: height,
        width: width,
        child: Column(
          children: [
            Container(
              height: height * 0.2,
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 30,
                      left: 15,
                      right: 15,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.sort,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfilePage()),
                                );
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: imageUrl != null
                                    ? NetworkImage(imageUrl!)
                                    : AssetImage('assets/Images/avatar.png') as ImageProvider,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((value) {
                              print("Signed Out");
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                                    (route) => false,
                              );
                            });
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.cyan, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: InkWell(
                          onTap: () {
                            // Handle New Appointment tap
                          },
                          child: Container(
                            width: 380,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xF6FAA1D3),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "New Appointment",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    'assets/Images/appointment.png',
                                    width: 110,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: InkWell(
                          onTap: () {
                            // Handle Your Schedule tap
                          },
                          child: Container(
                            width: 380,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xF6B062FA),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Your Schedule",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    'assets/Images/appointment.png',
                                    width: 110,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Text(
                          "Dental Care And Tips",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GridView.builder(
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          mainAxisSpacing: 25,
                          crossAxisSpacing: 20,
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: imgSrc.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {},
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 20),
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage(imgSrc[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    titles[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
