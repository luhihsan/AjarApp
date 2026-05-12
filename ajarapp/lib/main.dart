import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/login_page.dart';
import 'auth/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AjarApp());
}

class AjarApp extends StatelessWidget {
  const AjarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajar App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LandingPage(), 
    );
  }
}