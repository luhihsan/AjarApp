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
    required String jenisSoal,
    String? agama,
  }) async {

    if (_apiKey.isEmpty) {
      throw Exception("API Key tidak ditemukan. Pastikan file .env sudah diatur.");
    }
    
    final model = GenerativeModel(
      model: 'gemini-3.1-flash-lite',
      apiKey: _apiKey,
    );

    // 1. INSTRUKSI TIPE SOAL
    String instruksiTipe = "";
    if (jenisSoal == "Pilihan Ganda") {
      instruksiTipe = "Buatkan SEMUA soal dalam bentuk Pilihan Ganda (type: 'mcq'). Wajib isi array options.";
    } else if (jenisSoal == "Esai") {
      instruksiTipe = "Buatkan SEMUA soal dalam bentuk Isian/Esai (type: 'essay'). Wajib KOSONGKAN array options menjadi []. Pertanyaan harus berupa instruksi untuk menjelaskan/menyebutkan.";
    } else {
      instruksiTipe = "Buatkan soal CAMPURAN (sebagian Pilihan Ganda type: 'mcq', dan sebagian Esai type: 'essay').";
    }

    // 2. CONTOH JSON DINAMIS (Ini kunci agar AI tidak bingung)
    String contohJson = "";
    if (jenisSoal == "Pilihan Ganda") {
      contohJson = '''
      [
        {
          "type": "mcq",
          "question": "Apa fungsi klorofil pada daun?",
          "options": ["A. Menyerap air", "B. Menyerap cahaya", "C. Menghasilkan oksigen", "D. Menyimpan makanan"],
          "correctAnswer": "B. Menyerap cahaya",
          "explanation": "Klorofil berfungsi menyerap cahaya matahari untuk fotosintesis."
        }
      ]''';
    } else if (jenisSoal == "Esai") {
      contohJson = '''
      [
        {
          "type": "essay",
          "question": "Jelaskan dengan singkat apa fungsi klorofil pada tumbuhan!",
          "options": [],
          "correctAnswer": "Menyerap energi dari cahaya matahari untuk membantu proses fotosintesis.",
          "explanation": "Klorofil atau zat hijau daun memiliki peran utama dalam menyerap cahaya matahari."
        }
      ]''';
    } else {
      contohJson = '''
      [
        {
          "type": "mcq",
          "question": "Apa fungsi klorofil?",
          "options": ["A. Air", "B. Cahaya", "C. Oksigen", "D. Makanan"],
          "correctAnswer": "B. Cahaya",
          "explanation": "Klorofil menyerap cahaya."
        },
        {
          "type": "essay",
          "question": "Sebutkan 3 manfaat tumbuhan bagi manusia!",
          "options": [],
          "correctAnswer": "Sumber makanan, penghasil oksigen, dan bahan bangunan.",
          "explanation": "Tumbuhan sangat berguna karena..."
        }
      ]''';
    }

    final prompt = '''
     Kamu adalah seorang guru SD ahli yang kreatif dalam menyusun asesmen. Buatkan $jumlahSoal soal pilihan ganda untuk mata pelajaran $mapel.
      Target siswa: Kelas $kelas SD, Semester $semester.
      Tingkat kesulitan soal: $kesulitan.

      $instruksiTipe 
      
      Aturan ketat:
      1. Materi harus BENAR-BENAR sesuai dengan Capaian Pembelajaran (CP) Kurikulum Merdeka/K13 kelas $kelas SD semester $semester di Indonesia.
      2. VARIATIVITAS: Pastikan soal mencakup sub-topik yang berbeda dalam satu semester. Jangan hanya fokus pada satu bab. Gunakan variasi kata tanya (Mengapa, Bagaimana, Analisislah) dan hindari pengulangan pola kalimat.
      3. KONTEKSTUAL: Gunakan narasi atau situasi sehari-hari yang relevan dengan anak usia SD di Indonesia agar soal tidak terasa kaku/teoretis saja.
      4. DISTRAKTOR: Pilihan jawaban salah (distraktor) harus masuk akal dan tidak terlalu mencolok perbedaannya dengan jawaban benar.
      5. Kembalikan balasan HANYA dalam format array JSON yang valid tanpa markdown ```json atau teks pembuka/penutup lainnya.
      3. Format JSON HARUS MENGIKUTI STRUKTUR CONTOH INI: $contohJson
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
      model: 'gemini-3.1-flash-lite', 
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

  static Future<void> koreksiKuisByAI(List<QuestionModel> questions) async {
    if (_apiKey.isEmpty) throw Exception("API Key tidak ditemukan.");
    final model = GenerativeModel(model: 'gemini-3.1-flash-lite', apiKey: _apiKey);

    String dataKuis = "";
    for (int i = 0; i < questions.length; i++) {
      var q = questions[i];
      dataKuis += "Soal ${i + 1}:\n";
      dataKuis += "Tipe: ${q.type}\n";
      dataKuis += "Pertanyaan: ${q.question}\n";
      dataKuis += "Kunci Jawaban Seharusnya: ${q.correctAnswer}\n";
      dataKuis += "Jawaban Murid: ${q.userAnswer ?? 'Tidak dijawab'}\n\n";
    }

    final prompt = '''
      Kamu adalah guru pengoreksi ujian yang objektif. 
      Berikut adalah data soal, kunci jawaban, dan jawaban dari murid:
      
      $dataKuis

      Tugasmu:
      1. Koreksi setiap soal secara berurutan.
      2. Untuk soal "mcq" (Pilihan Ganda), berikan nilai 100 jika jawaban murid SAMA PERSIS dengan kunci. Berikan 0 jika salah.
      3. Untuk soal "essay" (Isian), EVALUASI SECARA SEMANTIK. Jangan kaku pada kecocokan kata persis. Jika maknanya benar atau mendekati, berikan nilai (misal 50, 75, 85, 100). Jika melenceng jauh, berikan 0.
      4. Berikan pesan evaluasi 1 kalimat pendek untuk tiap soal (contoh: "Tepat sekali!", atau "Hampir benar, harusnya ditambah kata oksigen.").
      5. Kembalikan HANYA format array JSON yang valid tanpa awalan/akhiran text, tanpa markdown ```json.
      
      Contoh Format Balasan:
      [
        {
          "score": 100,
          "feedback": "Jawabanmu tepat sekali!"
        },
        {
          "score": 60,
          "feedback": "Hampir benar, tapi fungsinya kurang lengkap."
        }
      ]
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final String responseText = response.text ?? '[]';
      final cleanedText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonList = jsonDecode(cleanedText);

      // 3. Masukkan hasil nilai dan feedback AI kembali ke model
      for (int i = 0; i < questions.length; i++) {
        if (i < jsonList.length) {
          questions[i].earnedScore = jsonList[i]['score'] ?? 0;
          questions[i].aiFeedback = jsonList[i]['feedback'] ?? "";
        }
      }
    } catch (e) {
      throw Exception("Gagal mengoreksi kuis: $e");
    }
  }
}
