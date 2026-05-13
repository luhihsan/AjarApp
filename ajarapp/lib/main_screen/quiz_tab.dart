import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizTab extends StatelessWidget {
  const QuizTab({super.key});

  // Palet Warna Konsisten
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
        title: Text(
          "Pilih Petualanganmu!", 
          style: GoogleFonts.nunito(fontSize: 24, color: darkBlueText, fontWeight: FontWeight.w900)
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BANNER TAMBAH MODUL CUSTOM (Fokus buat Ortu)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryBlue.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(color: primaryBlue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.library_add_rounded, color: primaryBlue, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Punya Materi Sendiri?", 
                          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Upload E-Book atau PDF (misal: Mulok Bahasa Jawa). AI kami akan otomatis membuatkan kuis dari materi tersebut!",
                    style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementasi File Picker & Kirim ke Gemini AI
                    },
                    icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
                    label: Text("Upload Modul / E-Book", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. KUIS MAPEL DEFAULT
            Text(
              "Mata Pelajaran Utama", 
              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: darkBlueText)
            ),
            const SizedBox(height: 16),

            // GridView untuk 4 Mapel
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Biar ga bentrok sama SingleChildScrollView
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Ngatur proporsi kotak
              children: [
                _buildSubjectCard(
                  title: "Matematika", 
                  icon: Icons.calculate_rounded, 
                  color: Colors.red.shade400,
                  onTap: () {} // TODO: Arahkan ke list kuis MTK
                ),
                _buildSubjectCard(
                  title: "Bahasa Indonesia", 
                  icon: Icons.menu_book_rounded, 
                  color: Colors.blue.shade400,
                  onTap: () {} // TODO: Arahkan ke list kuis B.Indo
                ),
                _buildSubjectCard(
                  title: "Bahasa Inggris", 
                  icon: Icons.abc_rounded, 
                  color: Colors.purple.shade400,
                  onTap: () {} // TODO: Arahkan ke list kuis Inggris
                ),
                _buildSubjectCard(
                  title: "IPAS", 
                  icon: Icons.biotech_rounded, 
                  color: Colors.green.shade400,
                  onTap: () {} // TODO: Arahkan ke list kuis IPAS
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Kotak Mata Pelajaran
  Widget _buildSubjectCard({
    required String title, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: color.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlueText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}