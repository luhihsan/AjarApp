import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth/landing_page.dart';
import 'main_screen/main_screen.dart';
// import 'firebase_options.dart'; // Buka komen ini kalau lo pakai firebase_options.dart dari flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load API Key Gemini
  await dotenv.load(fileName: ".env");
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Buka komen ini kalau pakai firebase_options
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajar App',
      debugShowCheckedModeBanner: false, // Ngilangin pita "DEBUG" di pojok kanan atas
      theme: ThemeData(
        primaryColor: const Color(0xFF67BEE0),
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
      ),
      // Alih-alih langsung ke LandingPage, kita lempar ke "Satpam" (AuthWrapper) dulu
      home: const AuthWrapper(), 
    );
  }
}

// --- KELAS SATPAM (AUTH WRAPPER) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ini akan selalu memantau status login user secara Real-Time
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Kalau lagi proses ngecek (loading)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFDFDFD),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF67BEE0)),
            ),
          );
        }

        // 2. Kalau terdeteksi ADA data user (Berarti token sesi masih aktif/valid)
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen(); // Langsung terobos ke Dashboard/Beranda
        }

        // 3. Kalau TIDAK ADA user (Belum login / Sudah logout)
        return const LandingPage(); // Lempar ke halaman awal untuk login
      },
    );
  }
}