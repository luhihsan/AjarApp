import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ajarapp/main_screen/dashboard_tab.dart';
import 'package:ajarapp/main_screen/quiz_tab.dart';
import 'package:ajarapp/main_screen/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);

  final List<Widget> _tabs = [
    const DashboardTab(), 
    const QuizTab(),    
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: accentOrange,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.extension_rounded), label: "Kuis"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
          ],
        ),
      ),
    );
  }
}