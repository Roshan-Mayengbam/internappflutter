import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/auth/registerpage.dart';
import 'package:internappflutter/auth/signup.dart';
import 'package:internappflutter/bottomnavbar.dart';

import 'package:internappflutter/firebase_options.dart';
import 'package:internappflutter/models/jobs.dart';
import 'package:provider/provider.dart';

import 'package:google_fonts/google_fonts.dart';

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
        // Add more providers here if needed
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkuser();
  }

  void _checkuser() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Timer(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
          setState(() {
            _errorMessage = "User not logged in";
          });
        });
      } else {
        Timer(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const BottomnavbarAlternative(userData: null),
            ),
          );
          setState(() {
            _errorMessage = "User not logged in";
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE8E1), // Light beige background
      body: Center(
        child: Text(
          'hyrup',
          style: GoogleFonts.pacifico(
            // or "GreatVibes", "DancingScript", etc.
            fontSize: 78,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
