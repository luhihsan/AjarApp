import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatelessWidget {
  // PARAMETER BARU UNTUK FILTER ANAK AKTIF
  final String childName;
  final String childId;
  final bool isFirstChild;

  const HistoryPage({
    super.key, 
    required this.childName, 
    required this.childId, 
    required this.isFirstChild
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF67BEE0);
    final Color darkBlueText = const Color(0xFF2C6C85);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text("Silakan login kembali.")));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text("Riwayat Belajar", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: darkBlueText)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkBlueText),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var allDocs = snapshot.data!.docs;
          
          // FILTER IN-MEMORY SAMA SEPERTI DI DASHBOARD
          var docs = allDocs.where((doc) {
             var data = doc.data() as Map<String, dynamic>;
             bool matchId = data['child_id'] == childId;
             bool matchName = data['child_name'] == childName;
             bool isLegacyData = data['child_id'] == null && data['child_name'] == null;
             
             return matchId || matchName || (isLegacyData && isFirstChild);
          }).toList();

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return _buildHistoryItem(docs[index], darkBlueText);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Belum ada riwayat kuis nih.", style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(QueryDocumentSnapshot doc, Color darkBlueText) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String mapel = data['mapel'] ?? "Kuis";
    int score = data['score'] ?? 0;
    DateTime tgl = (data['tanggal'] as Timestamp).toDate();
    
    String formattedDate = "${tgl.day}/${tgl.month}/${tgl.year}";
    bool isPassed = score >= 70;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded, 
              color: isPassed ? Colors.green : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mapel, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: darkBlueText)),
                Text(formattedDate, style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            "$score", 
            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: isPassed ? Colors.green : Colors.redAccent),
          ),
        ],
      ),
    );
  }
}