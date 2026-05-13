import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/question_model.dart'; 

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<List<QuestionModel>> generateQuiz({
    required String mapel,
    required int jumlahSoal,
    required String kesulitan,
    required String kelas, 
    required String semester, 
  }) async {

    if (_apiKey.isEmpty) {
      throw Exception("API Key tidak ditemukan. Pastikan file .env sudah diatur.");
    }
    
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
      Kamu adalah seorang guru SD yang ahli. Buatkan $jumlahSoal soal pilihan ganda untuk mata pelajaran $mapel.
      Target siswa: Kelas $kelas SD, Semester $semester.
      Tingkat kesulitan soal: $kesulitan.
      
      Aturan ketat:
      1. Materi harus BENAR-BENAR sesuai dengan kurikulum kelas $kelas SD semester $semester di Indonesia.
      2. Kembalikan balasan HANYA dalam format array JSON yang valid tanpa markdown ```json.
      3. Format JSON harus persis seperti ini:
      [
        {
          "question": "Apa fungsi klorofil pada daun?",
          "options": ["A. Menyerap air", "B. Menyerap cahaya", "C. Menghasilkan oksigen", "D. Menyimpan makanan"],
          "correctAnswer": "B. Menyerap cahaya",
          "explanation": "Klorofil berfungsi menyerap cahaya matahari untuk fotosintesis."
        }
      ]
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final String responseText = response.text ?? '[]';

      final cleanedText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonList = jsonDecode(cleanedText);
      
      return jsonList.map((json) => QuestionModel.fromJson(json)).toList();
      
    } catch (e) {
      throw Exception("Gagal membuat soal: $e");
    }
  }

    static Future<String> generateEvaluation({
    required List<QuestionModel> questions,
    required int score,
  }) async {
    if (_apiKey.isEmpty) {
      return "Evaluasi tidak tersedia (API Key kosong).";
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: _apiKey,
    );

    // 1. Rangkum data jawaban untuk di-audit oleh AI
    String hasilKuis = questions.map((q) {
      bool isCorrect = q.userAnswer == q.correctAnswer;
      return "- Soal: ${q.question}\n  Status: ${isCorrect ? 'Benar' : 'Salah'}";
    }).join("\n");

    // 2. Prompt Engineering Khusus Evaluasi
    final prompt = '''
      Kamu adalah seorang guru SD yang asik, ramah, dan sangat suportif.
      Seorang murid baru saja menyelesaikan kuis dengan nilai $score dari 100.
      
      Berikut adalah detail apa yang dia jawab dengan benar dan salah:
      $hasilKuis
      
      Tugasmu:
      Buatkan 1 paragraf singkat (maksimal 3-4 kalimat) berisi pujian, evaluasi spesifik tentang materi apa yang harus dia pelajari lagi berdasarkan soal yang berstatus 'Salah', dan motivasi penutup. 
      Jika nilainya 100, berikan pujian luar biasa.
      Gunakan bahasa yang sangat mudah dipahami anak SD. Dilarang keras menggunakan format markdown seperti bold (**) atau bullet points. Tulis murni sebagai paragraf biasa.
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "Tetap semangat dan rajin berlatih ya!";
    } catch (e) {
      return "Wah, koneksi ke ruang guru sedang terputus. Tetap semangat belajarnya ya!";
    }
  }
}
