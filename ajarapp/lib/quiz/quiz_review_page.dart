import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../services/gemini_service.dart';

class QuizReviewPage extends StatefulWidget {
  final List<QuestionModel> questions;
  final int score;

  const QuizReviewPage({super.key, required this.questions, required this.score});

  @override
  State<QuizReviewPage> createState() => _QuizReviewPageState();
}

class _QuizReviewPageState extends State<QuizReviewPage> {
  String _aiEvaluation = "Sedang menganalisis hasil belajarmu...";
  bool _isLoadingEval = true;

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);

  @override
  void initState() {
    super.initState();
    _getAIEvaluation();
  }

  Future<void> _getAIEvaluation() async {
    try {
      // Panggil AI secara dinamis berdasarkan data soal dan skor
      String eval = await GeminiService.generateEvaluation(
        questions: widget.questions, 
        score: widget.score
      );
      
      if (mounted) {
        setState(() {
          _aiEvaluation = eval;
          _isLoadingEval = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiEvaluation = "Aduh, gagal memuat evaluasi AI.";
          _isLoadingEval = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text("Pembahasan Kuis", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: darkBlueText)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkBlueText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AI EVALUATION CARD (Teacher's Note)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text("Pesan dari Guru AI", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18, color: darkBlueText)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingEval 
                    ? const LinearProgressIndicator() 
                    : Text(_aiEvaluation, style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text("Detail Jawaban", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: darkBlueText)),
            const SizedBox(height: 16),

            // 2. LIST PEMBAHASAN
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final q = widget.questions[index];
                bool isPassed = q.earnedScore >= 70; 

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isPassed ? Colors.green.shade100 : Colors.red.shade100, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Soal ${index + 1} (${q.type == 'mcq' ? 'Pilihan Ganda' : 'Esai'})", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text("Nilai: ${q.earnedScore}/100", style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: isPassed ? Colors.green : Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q.question, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlueText)),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow("Jawaban Kamu:", q.userAnswer ?? "Kosong", isPassed ? Colors.green : Colors.red),
                      _buildInfoRow("Kunci Jawaban:", q.correctAnswer, Colors.green),
                      
                      const SizedBox(height: 12),
                      const Divider(),
                      
                      // TAMPILAN FEEDBACK AI PER SOAL
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.mark_chat_read_rounded, size: 18, color: accentOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(q.aiFeedback, style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.bold, color: accentOrange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Penjelasan Materi: ${q.explanation}", style: GoogleFonts.quicksand(fontSize: 14, color: Colors.grey.shade700)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.quicksand(fontSize: 14, color: darkBlueText),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}