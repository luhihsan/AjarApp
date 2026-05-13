import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResultPage({
    super.key, 
    required this.score, 
    required this.totalQuestions, 
    required this.correctAnswers
  });

  @override
  Widget build(BuildContext context) {
    bool isPassed = score >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPassed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded, 
                size: 120, 
                color: isPassed ? const Color(0xFFFF8E00) : Colors.grey
              ),
              const SizedBox(height: 24),
              
              Text(
                isPassed ? "Hebat Banget!" : "Yuk, Coba Lagi!", 
                style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF2C6C85))
              ),
              const SizedBox(height: 8),
              Text(
                "Kamu berhasil menjawab $correctAnswers dari $totalQuestions soal dengan benar.", 
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF67BEE0).withOpacity(0.5), width: 2),
                ),
                child: Column(
                  children: [
                    Text("Nilai Kamu", style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C6C85))),
                    Text("$score", style: GoogleFonts.nunito(fontSize: 60, fontWeight: FontWeight.w900, color: const Color(0xFF67BEE0))),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: () {
                  // Kembali ke root (Dashboard / Main Screen)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8E00),
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