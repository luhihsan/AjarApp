import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/landing_page.dart';
import 'auth/onboarding_page.dart'; // IMPORT ONBOARDING
import 'main_screen/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF67BEE0),
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
      ),
      // Arahkan ke Splash/Decider Screen
      home: const InitialRouteDecider(), 
    );
  }
}

// --- KELAS PENENTU RUTE (Splash Screen & Decider) ---
class InitialRouteDecider extends StatefulWidget {
  const InitialRouteDecider({super.key});

  @override
  State<InitialRouteDecider> createState() => _InitialRouteDeciderState();
}

class _InitialRouteDeciderState extends State<InitialRouteDecider> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    // Beri sedikit jeda agar terasa seperti Splash Screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Cek apakah onboarding sudah dilihat
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      // Jika belum, lempar ke Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else {
      // Jika sudah, lempar ke AuthWrapper (Satpam Login)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ini berfungsi sebagai SPLASH SCREEN sederhana
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti logo sesuai kebutuhanmu
            Image.asset(
              'lib/assets/logo.png',
              width: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.school_rounded, size: 100, color: Color(0xFF67BEE0)),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFFFF8E00)),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFDFDFD),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF67BEE0))),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen(); 
        }

        return const LandingPage(); 
      },
    );
  }
}