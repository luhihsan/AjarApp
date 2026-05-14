import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart';
import '../quiz/quiz_config_page.dart'; 
import 'history_page.dart'; 

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  int _streak = 0;
  bool _isLoadingStreak = true;

  @override
  void initState() {
    super.initState();
    _initStreak();
  }

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
      return Scaffold(backgroundColor: bgColor, body: Center(child: CircularProgressIndicator(color: primaryBlue)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, parentSnap) {
        if (!parentSnap.hasData) return Scaffold(backgroundColor: bgColor, body: Center(child: CircularProgressIndicator(color: primaryBlue)));
        String? activeId = (parentSnap.data!.data() as Map<String, dynamic>?)?['active_child_id'];

        return StreamBuilder<QuerySnapshot>(
          // FIX FATAL BUG: Tambahkan orderBy createdAt
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('children').orderBy('createdAt').snapshots(),
          builder: (context, childrenSnap) {
            if (!childrenSnap.hasData || childrenSnap.data!.docs.isEmpty) {
              return Scaffold(backgroundColor: bgColor, body: Center(child: CircularProgressIndicator(color: primaryBlue)));
            }

            var childrenDocs = childrenSnap.data!.docs;
            QueryDocumentSnapshot activeChildDoc;
            
            try {
              activeChildDoc = activeId != null ? childrenDocs.firstWhere((d) => d.id == activeId) : childrenDocs.first;
            } catch (e) {
              activeChildDoc = childrenDocs.first;
            }

            var data = activeChildDoc.data() as Map<String, dynamic>;
            String namaAnak = data['nama_panggilan'] ?? "Jagoan";
            String childId = activeChildDoc.id;
            
            // LOGIC AMAN: Karena diurutkan, childrenDocs.first.id PASTI anak pertama yang diregister
            bool isFirstChild = childId == childrenDocs.first.id;
            
            int totalXp = data['xp'] ?? 0;
            var levelInfo = UserService.calculateLevelInfo(totalXp);
            
            int level = levelInfo['level']!;
            int currentXp = levelInfo['currentXp']!;
            int targetXp = levelInfo['targetXp']!;
            double progressPercent = currentXp / targetXp;

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Halo, $namaAnak! 👋", style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: darkBlueText)),
                                Text("Mau belajar apa hari ini?", style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          _buildStreakIcon(),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildLevelCard(level, currentXp, targetXp, progressPercent),
                      const SizedBox(height: 40),
                      Text("Ringkasan Belajarmu", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: darkBlueText)),
                      const SizedBox(height: 16),
                      _buildStatisticsAndHistory(user.uid, namaAnak, childId, isFirstChild), 
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreakIcon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: accentOrange.withOpacity(0.3))),
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
          CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Text("Lvl $level", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: accentOrange))),
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
                LinearProgressIndicator(value: progressPercent, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8, borderRadius: BorderRadius.circular(10)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatisticsAndHistory(String uid, String namaAnak, String childId, bool isFirstChild) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('history').orderBy('tanggal', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryBlue));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildPlaceholderStat();

        var allDocs = snapshot.data!.docs;
        
        var docs = allDocs.where((doc) {
           var data = doc.data() as Map<String, dynamic>;
           bool matchId = data['child_id'] == childId;
           bool matchName = data['child_name'] == namaAnak;
           bool isLegacyData = data['child_id'] == null && data['child_name'] == null;
           
           return matchId || matchName || (isLegacyData && isFirstChild);
        }).toList();

        if (docs.isEmpty) return _buildPlaceholderStat();

        int totalKuis = docs.length;
        int totalNilai = 0;
        Map<String, List<int>> skorPerMapel = {};

        for (var doc in docs) {
          var data = doc.data() as Map<String, dynamic>;
          int s = (data['score'] as num).toInt();
          String m = data['mapel'] ?? "Umum";
          totalNilai += s;
          if (skorPerMapel.containsKey(m)) {
            skorPerMapel[m]!.add(s);
          } else {
            skorPerMapel[m] = [s];
          }
        }
        int avgNilai = (totalNilai / totalKuis).round();

        String mapelTerlemah = "";
        double rataRataTerendah = 100.0;
        skorPerMapel.forEach((mapel, daftarNilai) {
          double avgMapel = daftarNilai.reduce((a, b) => a + b) / daftarNilai.length;
          if (avgMapel < rataRataTerendah) { rataRataTerendah = avgMapel; mapelTerlemah = mapel; }
        });

        var recentDocs = docs.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMetricCard("Total Kuis", "$totalKuis", Icons.assignment_turned_in_rounded, Colors.purple.shade400),
                const SizedBox(width: 16),
                _buildMetricCard("Rata-rata", "$avgNilai", Icons.auto_graph_rounded, avgNilai >= 70 ? Colors.green.shade400 : Colors.red.shade400),
              ],
            ),
            const SizedBox(height: 32),
            if (mapelTerlemah.isNotEmpty) ...[
              _buildRadarCard(mapelTerlemah, rataRataTerendah.round()), 
              const SizedBox(height: 32),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Riwayat Terakhir", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(childName: namaAnak, childId: childId, isFirstChild: isFirstChild))),
                  child: Text("Lihat Semua", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: accentOrange)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentDocs.map((doc) => _buildHistoryItem(doc)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildRadarCard(String mapel, int nilaiAvg) {
    bool isDanger = nilaiAvg < 70;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDanger ? Colors.red.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDanger ? Colors.red.shade200 : Colors.blue.shade200, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: isDanger ? Colors.red.shade400 : primaryBlue),
              const SizedBox(width: 8),
              Text("Analisis Guru AI", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: darkBlueText)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isDanger ? "Waduh, rata-rata nilai $mapel kamu masih $nilaiAvg nih. Yuk, kita perbanyak latihan di materi ini biar nilainya naik!" : "Hebat! Kamu paling butuh penguatan sedikit lagi di $mapel (Rata-rata: $nilaiAvg). Gas kuis lagi!",
            style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizConfigPage(mapel: mapel))),
            style: ElevatedButton.styleFrom(backgroundColor: isDanger ? Colors.redAccent : primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Text("Latihan $mapel Sekarang", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3), width: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            Text(title, style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String mapel = data['mapel'] ?? "Kuis";
    int score = data['score'] ?? 0;
    DateTime tgl = (data['tanggal'] as Timestamp).toDate();
    String formattedDate = "${tgl.day}/${tgl.month}/${tgl.year}";
    bool isPassed = score >= 70;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isPassed ? Colors.green.shade50 : Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isPassed ? Colors.green : Colors.redAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mapel, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlueText)),
                Text(formattedDate, style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
              ],
            ),
          ),
          Text("$score", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: isPassed ? Colors.green : Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderStat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.blue.shade50.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryBlue.withOpacity(0.1))),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 40, color: primaryBlue.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text("Belum ada data kuis nih.\nYuk ngerjain kuis biar muncul statistiknya!", textAlign: TextAlign.center, style: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}