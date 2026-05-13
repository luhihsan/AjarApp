import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, Bunda/Ayah!", style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            Text("Pantau Si Kecil", style: GoogleFonts.nunito(fontSize: 22, color: darkBlueText, fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(Icons.face_retouching_natural_rounded, color: accentOrange),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. REKOMENDASI AI SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.8)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text("Saran AI Pintar", style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Budi hebat di Matematika! Tapi sepertinya ia butuh latihan ekstra untuk IPAS materi 'Tata Surya'. Yuk coba kuisnya!",
                          style: GoogleFonts.quicksand(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Action mulai kuis rekomendasi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: darkBlueText,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Mulai", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. GRAFIK / STATISTIK PERFORMA MAPEL
            Text("Penguasaan Materi", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: darkBlueText)),
            const SizedBox(height: 16),
            _buildStatBar("Matematika", 0.85, Colors.green),
            _buildStatBar("Bahasa Indonesia", 0.70, primaryBlue),
            _buildStatBar("IPAS", 0.45, accentOrange), // Diberi warna beda agar mencolok kalau nilainya kurang
            
            const SizedBox(height: 32),

            // 3. AKTIVITAS TERAKHIR
            Text("Aktivitas Terakhir", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: darkBlueText)),
            const SizedBox(height: 16),
            _buildHistoryCard("Matematika: Pecahan", "Hari ini, 10:00", "+85 Poin", Icons.calculate_rounded),
            _buildHistoryCard("B. Indonesia: Membaca Cepat", "Kemarin", "+70 Poin", Icons.menu_book_rounded),
            _buildHistoryCard("Quiz Custom: Bahasa Jawa", "2 Hari lalu", "+90 Poin", Icons.translate_rounded),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Bar Statistik
  Widget _buildStatBar(String mapel, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mapel, style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, color: darkBlueText)),
              Text("${(progress * 100).toInt()}%", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk History Card
  Widget _buildHistoryCard(String title, String time, String score, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: darkBlueText)),
                Text(time, style: GoogleFonts.quicksand(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(score, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: accentOrange)),
        ],
      ),
    );
  }
}