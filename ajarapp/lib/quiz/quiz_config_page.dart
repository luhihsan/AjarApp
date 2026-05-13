import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/gemini_service.dart';
import '../models/question_model.dart';
import 'quiz_play_page.dart';

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

  // State Konfigurasi Soal
  double _jumlahSoal = 5;
  int _waktuMenit = 10;
  String _kesulitan = "Sedang";

  // State Data Anak
  String _kelasAnak = "";
  String _semesterAnak = "";
  bool _isLoadingData = true; // Buat nahan UI sebelum data anak keload

  @override
  void initState() {
    super.initState();
    _fetchChildData();
  }

  // LOGIC TARIK DATA ANAK DARI FIRESTORE
  Future<void> _fetchChildData() async {
    try {
      String uidOrtu = FirebaseAuth.instance.currentUser!.uid;
      
      // Ambil dokumen anak pertama dari sub-collection 'children'
      var childDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(uidOrtu)
          .collection('children')
          .limit(1)
          .get();

      if (childDocs.docs.isNotEmpty) {
        var data = childDocs.docs.first.data();
        setState(() {
          _kelasAnak = data['kelas'] ?? "Umum";
          _semesterAnak = data['semester'] ?? "Umum";
          _isLoadingData = false;
        });
      } else {
        // Fallback kalau ortu belum masukin data anak
        setState(() {
          _kelasAnak = "Umum";
          _semesterAnak = "Umum";
          _isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _kelasAnak = "Umum";
        _semesterAnak = "Umum";
        _isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kalau data anak belum ke-load, tampilin loading spinner
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

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
            // Header Info Anak (Biar transparan ke Ortu kalau soalnya udah dicustomize)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.face_retouching_natural_rounded, color: primaryBlue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Target Soal AI:", style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                        Text("Kelas $_kelasAnak SD - Semester $_semesterAnak", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: darkBlueText)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 1. Slider Jumlah Soal
            Text("Jumlah Soal: ${_jumlahSoal.toInt()}", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
            Slider(
              value: _jumlahSoal,
              min: 5,
              max: 20,
              divisions: 3, 
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
               showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min, // Agar dialog menyesuaikan tinggi konten
                      children: [
                        const SizedBox(height: 10),
                        CircularProgressIndicator(color: primaryBlue),
                        const SizedBox(height: 24),
                        Text(
                          "Sedang menyiapkan soal kuis...",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: darkBlueText,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "AI kami sedang meracik soal terbaik untukmu. Tunggu sebentar ya!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );

                try {
                  // MENGIRIM KELAS & SEMESTER KE GEMINI
                  List<QuestionModel> generatedQuestions = await GeminiService.generateQuiz(
                    mapel: widget.mapel,
                    jumlahSoal: _jumlahSoal.toInt(),
                    kesulitan: _kesulitan,
                    kelas: _kelasAnak,
                    semester: _semesterAnak,
                  );

                  if (context.mounted) Navigator.pop(context);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Soal berhasil dibuat!"), backgroundColor: Colors.green),
                    );
                    
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => QuizPlayPage(
                        questions: generatedQuestions, 
                        waktuMenit: _waktuMenit
                      ))
                    );
                  }
                } catch (e) {
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