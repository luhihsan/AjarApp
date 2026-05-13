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
}