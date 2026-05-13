import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/question_model.dart';
import 'quiz_result_page.dart';

class QuizPlayPage extends StatefulWidget {
  final List<QuestionModel> questions;
  final int waktuMenit;

  const QuizPlayPage({
    super.key,
    required this.questions,
    required this.waktuMenit,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;

  late Timer _timer;
  late int _timeLeftInSeconds;

  @override
  void initState() {
    super.initState();
    _timeLeftInSeconds = widget.waktuMenit * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
        } else {
          _timer.cancel();
          _cekJawabanLaluSelesai();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _timeLeftInSeconds ~/ 60;
    int seconds = _timeLeftInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _nextQuestion() {
    // Simpan jawaban user ke dalam model sebelum pindah
    widget.questions[_currentIndex].userAnswer = _selectedAnswer;

    if (_selectedAnswer == widget.questions[_currentIndex].correctAnswer) {
      _score++;
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      _cekJawabanLaluSelesai();
    }
  }

  void _cekJawabanLaluSelesai() {
    _timer.cancel();
    int finalScore = (_score / widget.questions.length * 100).round();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => QuizResultPage(
                score: finalScore,
                totalQuestions: widget.questions.length,
                correctAnswers: _score,
                questions: widget.questions, // Kirim list soal ke Result
            )));
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Yakin mau keluar?",
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold, color: darkBlueText)),
            content: Text(
                "Kuisnya belum selesai lho, progress kamu bakal hilang kalau keluar sekarang.",
                style: GoogleFonts.quicksand()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Lanjut Kuis",
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  _timer.cancel();
                  Navigator.of(context).pop(true);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text("Tetap Keluar",
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Tidak ada soal")));
    }

    final currentQ = widget.questions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: darkBlueText),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) Navigator.pop(context);
            },
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _timeLeftInSeconds < 60
                  ? Colors.red.shade50
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    color: _timeLeftInSeconds < 60 ? Colors.red : primaryBlue,
                    size: 20),
                const SizedBox(width: 8),
                Text(_formattedTime,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        color: _timeLeftInSeconds < 60
                            ? Colors.red
                            : primaryBlue)),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indikator Progress (Fix, tidak ikut ke-scroll)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Soal ${_currentIndex + 1} / ${widget.questions.length}",
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.questions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 24),

                // BAGIAN UTAMA YANG BISA DI-SCROLL (Pertanyaan + Pilihan Ganda)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kotak Pertanyaan
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.shade50,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ],
                            border: Border.all(
                                color: Colors.blue.shade50, width: 2),
                          ),
                          child: Text(
                            currentQ.question,
                            style: GoogleFonts.nunito(
                                fontSize: 18, // Font sedikit dikecilkan biar muat banyak
                                fontWeight: FontWeight.w800,
                                color: darkBlueText),
                            textAlign: TextAlign.left, // Rata kiri lebih baik untuk teks panjang
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Pilihan Jawaban
                        // Pakai ListView shrinkWrap di dalam SingleChildScrollView
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Scroll diurus oleh parent (SingleChildScrollView)
                          itemCount: currentQ.options.length,
                          itemBuilder: (context, index) {
                            String option = currentQ.options[index];
                            bool isSelected = _selectedAnswer == option;

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAnswer = option),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? accentOrange.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: isSelected
                                          ? accentOrange
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2.5 : 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? accentOrange
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: isSelected
                                                ? accentOrange
                                                : Colors.grey.shade400),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check_rounded,
                                              size: 20, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? accentOrange
                                              : darkBlueText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tombol Lanjut (Fix, selalu ada di bawah layar)
                ElevatedButton(
                  onPressed: _selectedAnswer == null ? null : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: _selectedAnswer == null ? 0 : 4,
                  ),
                  child: Text(
                      _currentIndex == widget.questions.length - 1
                          ? "Selesai"
                          : "Selanjutnya",
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedAnswer == null
                              ? Colors.grey.shade600
                              : Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}