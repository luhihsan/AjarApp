import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/question_model.dart'; // Import model yang tadi kita bikin

class GeminiService {
  static const String _apiKey = 'MASUKKAN_API_KEY_LO_DI_SINI';

  static Future<List<QuestionModel>> generateQuiz({
    required String mapel,
    required int jumlahSoal,
    required String kesulitan,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyALu_BSyAQo9p-JkHSMc0z7ILd5N8Niu98',
    );

    final prompt = '''
      Kamu adalah seorang guru SD yang ahli. Buatkan $jumlahSoal soal pilihan ganda untuk mata pelajaran $mapel.
      Tingkat kesulitan: $kesulitan.
      
      Aturan ketat:
      1. Kembalikan balasan HANYA dalam format array JSON yang valid.
      2. Dilarang menambahkan teks pengantar seperti "Berikut adalah soalnya" atau menggunakan markdown block ```json.
      3. Format JSON harus persis seperti ini:
      [
        {
          "question": "Apa fungsi klorofil pada daun?",
          "options": ["A. Menyerap air", "B. Menyerap cahaya matahari", "C. Menghasilkan oksigen", "D. Menyimpan makanan"],
          "correctAnswer": "B. Menyerap cahaya matahari",
          "explanation": "Klorofil berfungsi untuk menyerap energi dari cahaya matahari yang digunakan dalam proses fotosintesis."
        }
      ]
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final String responseText = response.text ?? '[]';
      final cleanedText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      // Parsing JSON dari AI ke bentuk List
      final List<dynamic> jsonList = jsonDecode(cleanedText);
      
      // Mapping dari JSON List ke List<QuestionModel>
      return jsonList.map((json) => QuestionModel.fromJson(json)).toList();
      
    } catch (e) {
      throw Exception("Gagal membuat soal: $e");
    }
  }
}