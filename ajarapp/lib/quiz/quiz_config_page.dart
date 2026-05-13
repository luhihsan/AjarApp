import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import '../models/question_model.dart';

class QuizConfigPage extends StatefulWidget {
  final String mapel;
  const QuizConfigPage({super.key, required this.mapel});

  @override
  State<QuizConfigPage> createState() => _QuizConfigPageState();
}

class _QuizConfigPageState extends State<QuizConfigPage> {
  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  // State untuk konfigurasi
  double _jumlahSoal = 5;
  int _waktuMenit = 10;
  String _kesulitan = "Sedang";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkBlueText),
        title: Text("Atur Kuis ${widget.mapel}", style: GoogleFonts.nunito(color: darkBlueText, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Icon
            Center(
              child: Icon(Icons.settings_suggest_rounded, size: 80, color: accentOrange),
            ),
            const SizedBox(height: 32),

            // 1. Slider Jumlah Soal
            Text("Jumlah Soal: ${_jumlahSoal.toInt()}", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
            Slider(
              value: _jumlahSoal,
              min: 5,
              max: 20,
              divisions: 3, // 5, 10, 15, 20
              activeColor: primaryBlue,
              inactiveColor: Colors.blue.shade100,
              label: _jumlahSoal.toInt().toString(),
              onChanged: (val) => setState(() => _jumlahSoal = val),
            ),
            const SizedBox(height: 24),

            // 2. Dropdown Waktu
            Text("Waktu Pengerjaan", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _waktuMenit,
                  isExpanded: true,
                  icon: Icon(Icons.timer_outlined, color: primaryBlue),
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText, fontSize: 16),
                  items: [5, 10, 15, 20, 30].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text("$val Menit"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _waktuMenit = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Pilihan Kesulitan
            Text("Tingkat Kesulitan", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDifficultyChip("Mudah", Colors.green),
                const SizedBox(width: 8),
                _buildDifficultyChip("Sedang", accentOrange),
                const SizedBox(width: 8),
                _buildDifficultyChip("Sulit", Colors.redAccent),
              ],
            ),
            const SizedBox(height: 50),

            // Tombol Generate
            ElevatedButton(
              onPressed: () async {
                // 1. Tampilkan Loading Dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                );

                try {
                  // 2. Panggil Gemini Service
                  List<QuestionModel> generatedQuestions = await GeminiService.generateQuiz(
                    mapel: widget.mapel,
                    jumlahSoal: _jumlahSoal.toInt(),
                    kesulitan: _kesulitan,
                  );

                  // 3. Tutup Loading
                  if (context.mounted) Navigator.pop(context);

                  // 4. Navigasi ke Halaman Kuis (QuizPlayPage)
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Soal berhasil dibuat!"), backgroundColor: Colors.green),
                    );
                    
                    // TODO: Arahkan ke QuizPlayPage dengan membawa data generatedQuestions
                    /*
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => QuizPlayPage(
                        questions: generatedQuestions, 
                        waktuMenit: _waktuMenit
                      ))
                    );
                    */
                  }
                } catch (e) {
                  // Tutup loading jika error
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Oops, gagal membuat soal: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
              child: Text("Buat Kuis Sekarang!", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, Color color) {
    bool isSelected = _kesulitan == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kesulitan = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}