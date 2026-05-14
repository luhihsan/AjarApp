import 'package:ajarapp/main_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/question_model.dart';
import 'quiz_review_page.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final List<QuestionModel> questions; 

  const QuizResultPage({
    super.key, 
    required this.score, 
    required this.totalQuestions, 
    required this.correctAnswers,
    required this.questions,
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    bool isPassed = score >= 70;
    
    final Color primaryBlue = const Color(0xFF67BEE0);
    final Color accentOrange = const Color(0xFFFF8E00);
    final Color darkBlueText = const Color(0xFF2C6C85);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                isPassed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded, 
                size: 120, 
                color: isPassed ? accentOrange : Colors.grey
              ),
              const SizedBox(height: 24),
              
              Text(
                isPassed ? "Hebat Banget!" : "Yuk, Coba Lagi!", 
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: darkBlueText)
              ),
              const SizedBox(height: 8),
              Text(
                "Kamu berhasil menjawab $correctAnswers dari $totalQuestions soal dengan benar.", 
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 40),

              // KOTAK NILAI
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: primaryBlue.withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    Text("Nilai Kamu", style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                    Text("$score", style: GoogleFonts.nunito(fontSize: 60, fontWeight: FontWeight.w900, color: primaryBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentOrange.withOpacity(0.5), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text("+$xpEarned XP", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: accentOrange)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizReviewPage(questions: questions, score: score),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), 
                    side: BorderSide(color: primaryBlue)
                  ),
                  elevation: 0,
                ),
                child: Text("Lihat Pembahasan & Evaluasi AI", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false, // Hapus semua tumpukan layar sebelumnya
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                child: Text("Kembali ke Beranda", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}