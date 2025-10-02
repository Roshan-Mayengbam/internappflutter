import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/auth/registerpage.dart';
import 'package:internappflutter/auth/signup.dart';
import 'package:internappflutter/bottomnavbar.dart';
import 'package:internappflutter/firebase_options.dart';

// Import for the OLD provider
import 'package:internappflutter/models/jobs.dart';

// Imports for the NEW provider (JProvider)
import 'package:internappflutter/features/data/datasources/job_response_remote_datasource.dart';
import 'package:internappflutter/features/data/repositories/job_repository_impl.dart';
import 'package:internappflutter/features/domain/usecases/get_jobs.dart';
import 'package:internappflutter/features/presentation/providers/job_provider.dart';

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
        // New provider from the features directory
        ChangeNotifierProvider(
          create: (_) => JProvider(
            getJobs: GetJobs(
              JobRepositoryImpl(
                remoteDataSource: JobRemoteDataSourceImpl(
                  client: http.Client(),
                  auth: FirebaseAuth.instance,
                ),
              ),
            ),
          ),
        ),
        // Old provider from the models directory
        ChangeNotifierProvider(create: (_) => JobProvider()),
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
      initialRoute: '/signup',
      routes: {
        '/homepage': (context) => const BottomnavbarAlternative(userData: null),
        '/signup': (context) => Page2(),
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
    // Auto navigate after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          // Navigate on tap
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              "Swipe. Match. Get Hired.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy SignUpScreen for navigation
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: const Center(child: Text("Sign Up Screen")),
    );
  }
}
