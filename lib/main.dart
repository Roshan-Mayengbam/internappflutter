import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/auth/registerpage.dart';
import 'package:internappflutter/bottomnavbar.dart';

import 'package:internappflutter/firebase_options.dart';
import 'package:internappflutter/models/jobs.dart';

// Imports for the NEW provider (JProvider)
import 'package:internappflutter/features/AvailableJobs/data/datasources/job_response_remote_datasource.dart';
import 'package:internappflutter/features/AvailableJobs/data/repositories/job_repository_impl.dart';
import 'package:internappflutter/features/presentation/providers/job_provider.dart';

import 'features/AvailableJobs/domain/usecases/get_jobs.dart';
import 'features/NewsFeed/data/datasources/guardian_api_remote_datasource.dart';
import 'features/NewsFeed/data/repositories/news_repository_impl.dart';
import 'features/NewsFeed/domain/usecases/get_tech_news.dart';
import 'features/presentation/providers/news_provider.dart';
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
        ChangeNotifierProvider(
          create: (_) => ExploreViewModel(
            getNewsUseCase: GetTechNewsUseCase(
              NewsRepositoryImpl(remoteDataSource: GuardianApiDataSource()),
            ),
          ),
        ),
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
  static const String baseUrl =
      'https://hyrup-730899264601.asia-south1.run.app/student';

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() {
    Timer(const Duration(seconds: 3), _checkUser);
  }

  Future<Map<String, dynamic>?> _checkIfUserExists() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("❌ No authenticated user found");
        return null;
      }

      print("🔑 Getting ID token...");
      final idToken = await currentUser.getIdToken();
      print("✅ ID token obtained");

      final response = await http
          .get(
            Uri.parse("$baseUrl/check"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $idToken",
            },
          )
          .timeout(Duration(seconds: 30));

      print("📡 Backend response status: ${response.statusCode}");
      print("📄 Backend response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['exists'] == true &&
            responseData.containsKey('user')) {
          print("✅ User exists in database");
          return {"exists": true, "user": responseData['user']};
        } else if (responseData['exists'] == false) {
          print("👤 User does not exist in database");
          return {"exists": false};
        }
      } else if (response.statusCode == 404) {
        print("👤 User not found in database (404)");
        return {"exists": false};
      }

      return null;
    } catch (e) {
      print("❌ Error checking user: $e");
      return null;
    }
  }

  Future<void> _checkUser() async {
    try {
      // Check Firebase authentication
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("❌ No Firebase user - redirecting to login");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page2()),
        );
        return;
      }

      print("✅ Firebase user found: ${user.uid}");

      // Check backend database
      final userCheckResult = await _checkIfUserExists();

      if (userCheckResult == null) {
        print("❌ Error checking backend - redirecting to login");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page2()),
        );
        return;
      }

      if (!mounted) return;

      if (userCheckResult['exists'] == true) {
        print("✅ User exists - going to main app");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BottomnavbarAlternative(userData: userCheckResult['user']),
          ),
        );
      } else {
        print("⚠️ User needs registration");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page2()),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Page2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      body: Center(
        child: Text(
          'hyrup',
          style: GoogleFonts.pacifico(
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
