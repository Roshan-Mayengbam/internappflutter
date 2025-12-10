import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/network/network_service.dart';
import 'package:internappflutter/features/core/network/network_service_impl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:internappflutter/features/AvailableHackathons/data/datasource/hackathon_datasource.dart';
import 'package:internappflutter/features/AvailableHackathons/data/repository/hackathon_repo_impl.dart';
import 'package:internappflutter/features/AvailableHackathons/domain/usecases/fetch_similar_hackathons.dart';
import 'package:internappflutter/features/AvailableHackathons/presentation/provider/hackathon_provider.dart';

import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/auth/registerpage.dart';
import 'package:internappflutter/bottomnavbar.dart';

import 'package:internappflutter/firebase_options.dart';
import 'package:internappflutter/models/jobs.dart';
import 'package:internappflutter/screens/hackathon.dart';

// Imports for the NEW provider (JProvider)
import 'package:internappflutter/features/AvailableJobs/data/datasources/job_response_remote_datasource.dart';
import 'package:internappflutter/features/AvailableJobs/data/repositories/job_repository_impl.dart';
import 'package:internappflutter/features/AvailableJobs/presentation/provider/job_provider.dart';

import 'features/AvailableJobs/domain/usecases/get_jobs.dart';
import 'features/NewsFeed/data/datasources/guardian_api_remote_datasource.dart';
import 'features/NewsFeed/data/repositories/news_repository_impl.dart';
import 'features/NewsFeed/domain/usecases/get_tech_news.dart';
import 'features/NewsFeed/presentation/provider/news_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/NewsFeed/domain/entities/article.dart';
import 'features/NewsFeed/data/datasources/news_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase using default options for the current platform
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      if (kDebugMode) print('Error initializing Firebase: $e');
    }
  }

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());

  runApp(
    MultiProvider(
      providers: [
        Provider<NetworkService>(
          // Use the concrete implementation
          create: (_) => NetworkServiceImpl(),
        ),
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
        ChangeNotifierProvider(
          create: (_) => HProvider(
            getSimilarHackathons: GetSimilarHackathons(
              repository: HackathonRepositoryImpl(
                remoteDataSource: HackathonRemoteDataSourceImpl(
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
              NewsRepositoryImpl(
                remoteDataSource: GuardianApiDataSource(),
                localDataSource: NewsLocalDataSourceImpl(),
              ),
            ),
            networkService: NetworkServiceImpl(),
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
      title: 'Hyrup',
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
        if (kDebugMode) print("❌ No authenticated user found");
        return null;
      }

      if (kDebugMode) print("🔑 Getting ID token...");
      final idToken = await currentUser.getIdToken();
      if (kDebugMode) print("✅ ID token obtained");

      final response = await http
          .get(
            Uri.parse("$baseUrl/check"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $idToken",
            },
          )
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print("📡 Backend response status: ${response.statusCode}");
      }
      if (kDebugMode) print("📄 Backend response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['exists'] == true &&
            responseData.containsKey('user')) {
          if (kDebugMode) print("✅ User exists in database");
          return {"exists": true, "user": responseData['user']};
        } else if (responseData['exists'] == false) {
          if (kDebugMode) print("👤 User does not exist in database");
          return {"exists": false};
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) print("👤 User not found in database (404)");
        return {"exists": false};
      }

      return null;
    } catch (e) {
      if (kDebugMode) print("❌ Error checking user: $e");
      return null;
    }
  }

  Future<void> _checkUser() async {
    try {
      // Check Firebase authentication
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (kDebugMode) print("❌ No Firebase user - redirecting to login");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page2()),
        );
        return;
      }

      if (kDebugMode) print("✅ Firebase user found: ${user.uid}");

      // Check backend database
      final userCheckResult = await _checkIfUserExists();

      if (userCheckResult == null) {
        if (kDebugMode) {
          print("❌ Error checking backend - redirecting to login");
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page2()),
        );
        return;
      }

      if (!mounted) return;

      if (userCheckResult['exists'] == true) {
        if (kDebugMode) print("✅ User exists - going to main app");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BottomnavbarAlternative(userData: userCheckResult['user']),
          ),
        );
      } else {
        if (kDebugMode) print("⚠️ User needs registration");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page2()),
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error: $e");
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
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/hyrup/splash_logo.json',
          fit: BoxFit.fitWidth,
          animate: true,
        ),
      ),
    );
  }
}

class UploadCollegesPage extends StatefulWidget {
  @override
  State<UploadCollegesPage> createState() => _UploadCollegesPageState();
}

class _UploadCollegesPageState extends State<UploadCollegesPage> {
  bool isUploading = false;

  Future<void> uploadColleges() async {
    setState(() {
      isUploading = true;
    });

    final List<Map<String, dynamic>> colleges = [
  { "name": "A.C. College of Engineering and Technology" },
  { "name": "A.R. College of Engineering and Technology" },
  { "name": "A.V.C. College of Engineering" },
  { "name": "Aalim Muhammed Salegh College of Engineering" },
  { "name": "Adhiparasakthi College of Engineering" },
  { "name": "Adhiparasakthi Engineering College" },
  { "name": "Adithya Institute of Technology" },
  { "name": "Aishwarya College of Engineering and Technology" },
  { "name": "Akshaya College of Engineering and Technology" },
  { "name": "Alagappa College of Technology" },
  { "name": "Alex College of Engineering and Technology" },
  { "name": "Angel College of Engineering and Technology" },
  { "name": "Anjalai Ammal Mahalingam Engineering College" },
  { "name": "Annai College of Engineering and Technology" },
  { "name": "Annai Mathammal Sheela Engineering College" },
  { "name": "Annai Mira College of Engineering and Technology" },
  { "name": "Annai Teresa College of Engineering" },
  { "name": "Annamalaiar College of Engineering" },
  { "name": "Arasu Engineering College" },
  { "name": "Arignar Anna Institute of Science and Technology" },
  { "name": "Arjun College of Technology" },
  { "name": "Arulmigu Meenakshi Amman College of Engineering" },
  { "name": "Arulmurugan College of Engineering" },
  { "name": "As-Salam College of Engineering and Technology" },
  { "name": "Audisankara College of Engineering for Women" },
  { "name": "AVS Engineering College" },
  { "name": "Bannari Amman Institute of Technology" },
  { "name": "Bethlahem Institute of Engineering" },
  { "name": "Bharath Institute of Higher Education and Research" },
  { "name": "Bharathiyar Institute of Engineering for Women" },
  { "name": "Bharath Niketan Engineering College" },
  { "name": "Bharath University - BIHER" },
  { "name": "C Abdul Hakeem College of Engineering and Technology" },
  { "name": "C.K. College of Engineering and Technology" },
  { "name": "C.M.S. College of Engineering and Technology" },
  { "name": "C.R. College of Engineering and Technology" },
  { "name": "Cape Institute of Technology" },
  { "name": "Chandy College of Engineering" },
  { "name": "Chendhuran College of Engineering and Technology" },
  { "name": "Cheran College of Engineering" },
  { "name": "Chennai Institute of Technology" },
  { "name": "Christian College of Engineering and Technology" },
  { "name": "Coimbatore Institute of Engineering and Technology" },
  { "name": "Coimbatore Institute of Technology" },
  { "name": "CSI College of Engineering" },
  { "name": "CSI Institute of Technology" },
  { "name": "D.M.I. College of Engineering" },
  { "name": "Dhanalakshmi College of Engineering" },
  { "name": "Dhanalakshmi Srinivasan College of Engineering" },
  { "name": "Dhanalakshmi Srinivasan Engineering College" },
  { "name": "Dhaanish Ahmed College of Engineering" },
  { "name": "Dhaanish Ahmed Institute of Technology" },
  { "name": "Don Bosco College of Engineering" },
  { "name": "Dr. M.G.R. Educational and Research Institute" },
  { "name": "Dr. N.G.P. Institute of Technology" },
  { "name": "Dr. Sivanthi Aditanar College of Engineering" },
  { "name": "Ebenezer College of Engineering and Technology" },
  { "name": "Edayathangudy G S Pillay Engineering College" },
  { "name": "E.G.S. Pillay Engineering College" },
  { "name": "Erode Builder Educational Trust's Group of Institutions" },
  { "name": "Excel College of Engineering and Technology" },
  { "name": "Excel Engineering College" },
  { "name": "Excel Institute of Engineering and Technology" },
  { "name": "SNS College of Engineering" },
  { "name": "SNS College of Technology" },
  { "name": "Sona College of Technology" },
  { "name": "Francis Xavier Engineering College" },
  { "name": "G.K.M. College of Engineering and Technology" },
  { "name": "Gnanamani College of Technology" },
  { "name": "Gojan School of Business and Technology" },
  { "name": "Government College of Engineering, Bargur" },
  { "name": "Government College of Engineering, Bodinayakanur" },
  { "name": "Government College of Engineering, Dharmapuri" },
  { "name": "Government College of Engineering, Salem" },
  { "name": "Government College of Engineering, Tirunelveli" },
  { "name": "Government College of Technology, Coimbatore" },
  { "name": "Hindustan College of Engineering and Technology" },
  { "name": "Hindusthan Institute of Technology" },
  { "name": "Holy Kings College of Engineering and Technology" },
  { "name": "Idhaya Engineering College for Women" },
  { "name": "Immanuel Arasar JJ College of Engineering" },
  { "name": "Indira Gandhi College of Engineering and Technology for Women" },
  { "name": "Indra Ganesan College of Engineering" },
  { "name": "Info Institute of Engineering" },
  { "name": "J.J. College of Engineering and Technology" },
  { "name": "J.K.K. Nattraja College of Engineering and Technology" },
  { "name": "Jai Shriram Engineering College" },
  { "name": "Jairupaa Institute of Engineering" },
  { "name": "Jansons Institute of Technology" },
  { "name": "Jaya College of Engineering and Technology" },
  { "name": "Jaya Engineering College" },
  { "name": "Jayaraj Annapackiam CSI College of Engineering" },
  { "name": "Jeppiaar Engineering College" },
  { "name": "Jerusalem College of Engineering" }
];




    try {
      final collection = FirebaseFirestore.instance.collection("colleges");
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var college in colleges) {
        final docName = college['name']!.replaceAll('/', '-');
        final doc = collection.doc(docName);

        // Add searchName field for case-insensitive searching
        batch.set(doc, {
          ...college,
          'searchName': college['name']!.toLowerCase(),
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploaded ${colleges.length} colleges 🎉")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Colleges"), centerTitle: true),
      body: Center(
        child: isUploading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Uploading... Please wait"),
                ],
              )
            : ElevatedButton(
                onPressed: uploadColleges,
                child: Text("Upload Colleges to Firestore"),
              ),
      ),
    );
  }
}
