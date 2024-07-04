import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tooth_tales/screens/article.dart';
import 'package:tooth_tales/screens/chat.dart';
import 'package:tooth_tales/screens/doctorProfile.dart';
import 'package:tooth_tales/screens/login.dart';
import 'package:tooth_tales/screens/patientProfile.dart';
import 'package:tooth_tales/screens/schedule.dart';
import 'package:tooth_tales/screens/signup.dart';
import 'package:tooth_tales/start.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tooth_tales/constants/constant.dart';
import 'screens/footer.dart';
import 'screens/desc.dart';
import 'screens/doctor.dart';
import 'screens/alarm.dart';
import 'screens/alarm_start.dart';
import 'screens/appointment.dart';
import 'screens/oralhealth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FIREBASE_API_KEY,
      appId: APPID,
      messagingSenderId: MessagingSenderId,
      projectId: ProjectId,
      storageBucket: StorageBucket,
    ),
  );
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/desc':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args.containsKey('doctorId')) {
              return MaterialPageRoute(
                builder: (context) => DescriptionScreen(
                  doctorId: args['doctorId'],
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Error: Missing doctorId argument'),
                ),
              ),
            );
          case '/appointment':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args.containsKey('doctorId') && args.containsKey('selectedSlot')) {
              return MaterialPageRoute(
                builder: (context) => AppointmentScreen(
                  doctorId: args['doctorId'],
                  selectedSlot: args['selectedSlot'],
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Error: Missing doctorData or selectedSlot argument'),
                ),
              ),
            );
          default:
            return null;
        }
      },
      routes: {
        '/footer': (context) => FooterScreen(),
        '/alarm': (context) => BrushingAlarmPage(),
        '/alarmstart': (context) => BrushingAlarmScreen(),
        '/doctor': (context) => DoctorScreen(),
        '/oralhealth': (context) => OralHealthTipsPage(),
        '/schedule': (context) => ScheduleScreen(),
        '/chat': (context) => ChatScreen(),
        '/articles': (context) => ArticleListScreen(),
        'patient_profile' : (context) => ProfilePage(),
        '/doctor-profile': (context) => DoctorProfilePage(),
      },

    );
  }
}
