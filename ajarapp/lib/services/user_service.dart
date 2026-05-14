import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Map<String, int> calculateLevelInfo(int totalXp) {
    int level = 1;
    int currentTarget = 100;
    int accumulatedXp = totalXp;

    while (accumulatedXp >= currentTarget) {
      accumulatedXp -= currentTarget;
      level++;
      currentTarget += 50; 
    }

    return {
      'level': level,
      'currentXp': accumulatedXp,
      'targetXp': currentTarget,
    };
  }

  static Future<DocumentSnapshot?> getActiveChild() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    var parentDoc = await _db.collection('users').doc(user.uid).get();
    String? activeId = (parentDoc.data() as Map<String, dynamic>?)?['active_child_id'];

    // FIX FATAL BUG: Wajib diurutkan berdasarkan waktu daftar
    var childrenDocs = await _db.collection('users').doc(user.uid).collection('children').orderBy('createdAt').get();
    if (childrenDocs.docs.isEmpty) return null;

    if (activeId != null) {
      try {
        return childrenDocs.docs.firstWhere((doc) => doc.id == activeId);
      } catch (e) {}
    }

    String firstId = childrenDocs.docs.first.id;
    await _db.collection('users').doc(user.uid).update({'active_child_id': firstId});
    return childrenDocs.docs.first;
  }

  static Future<int> saveQuizResult({
    required String mapel,
    required int score,
    required List<QuestionModel> questions,
    required String childName,
    required String kesulitan,
    required int waktuMenit,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return 0;

    var activeChild = await getActiveChild(); 
    if (activeChild == null) return 0;

    DocumentReference childRef = activeChild.reference;
    var childData = activeChild.data() as Map<String, dynamic>;

    int jumlahSoal = questions.length;
    double baseXp = (score / 100.0) * (jumlahSoal * 10); 

    double diffMultiplier = 1.0;
    if (kesulitan == "Sedang") diffMultiplier = 1.5;
    if (kesulitan == "Sulit") diffMultiplier = 2.0;

    double timeMultiplier = 1.0;
    if (waktuMenit <= 5) timeMultiplier = 1.5;
    else if (waktuMenit <= 10) timeMultiplier = 1.2;
    else if (waktuMenit <= 15) timeMultiplier = 1.0;
    else timeMultiplier = 0.8;

    int finalXpEarned = (baseXp * diffMultiplier * timeMultiplier).round();
    if (finalXpEarned == 0 && score > 0) finalXpEarned = 5;

    await _db.collection('users').doc(user.uid).collection('history').add({
      'mapel': mapel,
      'score': score,
      'xp_earned': finalXpEarned,
      'kesulitan': kesulitan,
      'child_name': childName,
      'child_id': activeChild.id, 
      'tanggal': DateTime.now(),
      'jumlah_soal': jumlahSoal,
    });

    int xpLama = childData['xp'] ?? 0;
    await childRef.update({
      'xp': xpLama + finalXpEarned,
      'last_played': DateTime.now(),
    });

    return finalXpEarned; 
  }

  static Future<int> updateAndGetStreak() async {
    User? user = _auth.currentUser;
    if (user == null) return 0;

    var activeChild = await getActiveChild(); 
    if (activeChild == null) return 0;

    var childRef = activeChild.reference;
    var data = activeChild.data() as Map<String, dynamic>;

    DateTime now = DateTime.now();
    DateTime? lastLogin = (data['last_login'] as Timestamp?)?.toDate();
    int currentStreak = data['streak'] ?? 0;

    if (lastLogin == null) {
      currentStreak = 1;
    } else {
      int selisihHari = now.difference(lastLogin).inDays;
      if (selisihHari == 1) {
        currentStreak += 1;
      } else if (selisihHari > 1) {
        currentStreak = 1;
      }
    }

    await childRef.update({'last_login': now, 'streak': currentStreak});
    return currentStreak;
  }
}