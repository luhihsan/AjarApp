import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart'; // Pastikan import UserService

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);

  int _streak = 0;
  bool _isLoadingStreak = true;

  @override
  void initState() {
    super.initState();
    _initStreak();
  }

  // Kita cuma panggil logic Streak sekali pas aplikasi dibuka
  Future<void> _initStreak() async {
    try {
      int s = await UserService.updateAndGetStreak();
      if (mounted) {
        setState(() {
          _streak = s;
          _isLoadingStreak = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStreak = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _isLoadingStreak) {
      return const Center(child: CircularProgressIndicator());
    }

    // STREAM BUILDER: Mendengarkan perubahan data di Firebase secara Real-Time
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Ambil data terbaru dari Stream
        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        String namaAnak = data['nama_panggilan'] ?? "Jagoan";
        int xp = data['xp'] ?? 0;
        int level = (xp ~/ 100) + 1;

        int xpNextLevel = 100;
        int xpProgress = xp % xpNextLevel;
        double progressPercent = xpProgress / xpNextLevel;

        return Scaffold(
          backgroundColor: const Color(0xFFFDFDFD),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo, $namaAnak! 👋", 
                              style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: darkBlueText),
                            ),
                            Text(
                              "Mau belajar apa hari ini?",
                              style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      _buildStreakIcon(),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // CARD LEVEL (GAMIFIKASI) - Akan update instan saat nilai XP berubah!
                  _buildLevelCard(level, xpProgress, xpNextLevel, progressPercent),
                  
                  const SizedBox(height: 40),

                  Text("Ringkasan Belajarmu", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: darkBlueText)),
                  const SizedBox(height: 16),
                  _buildPlaceholderStat(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakIcon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text("🔥", style: TextStyle(fontSize: 20)),
          const SizedBox(width: 4),
          Text("$_streak Hari", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: accentOrange)),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int level, int xpProgress, int xpNextLevel, double progressPercent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, const Color(0xFF4A90E2)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text("Lvl $level", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: accentOrange)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Petualang Cilik", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("$xpProgress / $xpNextLevel XP", style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceholderStat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.1), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 40, color: primaryBlue.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            "Belum ada data kuis nih.\nYuk ngerjain kuis biar muncul statistiknya!",
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}