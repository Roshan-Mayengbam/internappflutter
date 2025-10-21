import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/auth/registerpage.dart';
import 'package:internappflutter/bottomnavbar.dart';

import 'package:internappflutter/firebase_options.dart';
import 'package:internappflutter/models/jobs.dart';
import 'package:internappflutter/screens/hackathon.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase using default options for the current platform
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => HackathonProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/homepage': (context) => const BottomnavbarAlternative(userData: null),
        '/signup': (context) => Page2(),
        '/': (context) => SplashScreen(),
        '/register': (context) => RegisterPage(userModel: null),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() {
    // Wait for 3 seconds before checking user
    Timer(const Duration(seconds: 3), _checkUser);
  }

  void _checkUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Page2()),
      );
      setState(() {});
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomnavbarAlternative(userData: null),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF), // light cream background
      body: Center(
        child: Text(
          'hyrup',
          style: GoogleFonts.pacifico(
            // similar to the image font
            fontSize: 84,
            color: Colors.black,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
