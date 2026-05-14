import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../auth/landing_page.dart';
import '../auth/register_child_page.dart';
import '../services/user_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Keluar Aplikasi", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text("Apakah Anda yakin ingin mengakhiri sesi saat ini?", style: GoogleFonts.quicksand(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text("Keluar", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      )
    );
  }

  void _setActiveChild(String parentUid, String childId) {
    FirebaseFirestore.instance.collection('users').doc(parentUid).update({'active_child_id': childId});
  }

  Future<void> _generateDetailedReport(BuildContext context, Map<String, dynamic> childData, Map<String, dynamic> insight) async {
    final pdf = pw.Document();
    String nama = childData['nama_panggilan'] ?? "Jagoan";
    List<String> mapelFav = List<String>.from(childData['mapel_fav'] ?? []);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('LAPORAN CAPAIAN BELAJAR', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('AJAR APP', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Data Siswa:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Nama: $nama'),
                pw.Text('Kelas: ${childData['kelas']} SD'),
                pw.Text('Mapel Favorit: ${mapelFav.join(", ")}'),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('Analisis Performa AI', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Bullet(text: 'Materi Paling Dikuasai: ${insight['strongest']}'),
                pw.Bullet(text: 'Materi Perlu Latihan: ${insight['weakest']}'),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(color: PdfColors.amber50, border: pw.Border.all(color: PdfColors.amber)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Rekomendasi Guru AI:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(insight['advice']),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Center(child: pw.Text('Laporan otomatis • © 2026 Ajar App', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Laporan_Belajar_$nama.pdf');
  }

  Future<Map<String, dynamic>> _getChildInsight(String uid, String childName) async {
    var history = await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('history')
        .get(); 

    var childHistory = history.docs.where((doc) {
      return (doc.data())['child_name'] == childName;
    }).toList();

    if (childHistory.isEmpty) {
      return {'strongest': '-', 'weakest': '-', 'advice': 'Belum ada data belajar yang cukup untuk dianalisis.'};
    }

    Map<String, List<int>> stats = {};
    for (var doc in childHistory) {
      var data = doc.data();
      String m = data['mapel'];
      int s = data['score'];
      stats.containsKey(m) ? stats[m]!.add(s) : stats[m] = [s];
    }

    String strongest = ""; String weakest = "";
    double high = -1; double low = 101;

    stats.forEach((mapel, scores) {
      double avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg > high) { high = avg; strongest = mapel; }
      if (avg < low) { low = avg; weakest = mapel; }
    });

    return {
      'strongest': strongest,
      'weakest': weakest,
      'advice': low < 70 ? "Fokuslah pada materi $weakest. Yuk sering latihan lagi!" : "Luar biasa! Pertahankan konsistensimu.",
    };
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF67BEE0);
    final Color accentOrange = const Color(0xFFFF8E00);
    final Color darkBlueText = const Color(0xFF2C6C85);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Sesi habis"));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: Text("Profil Keluarga", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: darkBlueText)),
        backgroundColor: Colors.white, elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Keluar',
            onPressed: () => _confirmLogout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: primaryBlue, child: const Icon(Icons.person, color: Colors.white)),
              title: Text(user.email ?? "", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
              subtitle: Text("Akun Orang Tua", style: GoogleFonts.quicksand()),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Daftar Anak", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterChildPage(uidOrtu: user.uid))),
                  icon: const Icon(Icons.add), label: const Text("Tambah Anak"),
                )
              ],
            ),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, parentSnap) {
                if (!parentSnap.hasData) return const Center(child: CircularProgressIndicator());
                String? activeId = (parentSnap.data!.data() as Map<String, dynamic>?)?['active_child_id'];

                return StreamBuilder<QuerySnapshot>(
                  // FIX FATAL BUG: Tambahkan orderBy createdAt di sini juga
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('children').orderBy('createdAt').snapshots(),
                  builder: (context, childrenSnap) {
                    if (!childrenSnap.hasData) return const Center(child: CircularProgressIndicator());
                    
                    var docs = childrenSnap.data!.docs;
                    if (docs.isEmpty) return const Text("Belum ada data anak.");

                    if (activeId == null || !docs.any((d) => d.id == activeId)) {
                      activeId = docs.first.id;
                      _setActiveChild(user.uid, activeId!); 
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var doc = docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        String name = data['nama_panggilan'] ?? "Anak";
                        List<String> favs = List<String>.from(data['mapel_fav'] ?? []);
                        bool isActive = doc.id == activeId;

                        int totalXp = data['xp'] ?? 0;
                        var levelInfo = UserService.calculateLevelInfo(totalXp);

                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getChildInsight(user.uid, name),
                          builder: (context, insightSnap) {
                            var insight = insightSnap.data ?? {'strongest': '...', 'weakest': '...', 'advice': '...'};

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
                                border: Border.all(color: isActive ? primaryBlue.withOpacity(0.5) : Colors.grey.shade200, width: isActive ? 2 : 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 25, backgroundColor: isActive ? accentOrange.withOpacity(0.1) : Colors.grey.shade300, child: Text(name[0], style: TextStyle(color: isActive ? accentOrange : Colors.grey, fontWeight: FontWeight.bold))),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? darkBlueText : Colors.grey)),
                                            Text("Kelas ${data['kelas']} SD • Lvl ${levelInfo['level']}", style: GoogleFonts.quicksand(color: Colors.grey, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      if (isActive)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                                          child: Text("Aktif", style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                        )
                                    ],
                                  ),
                                  
                                  if (isActive) ...[
                                    const SizedBox(height: 20),
                                    Text("Mata Pelajaran Favorit:", style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.bold)),
                                    Wrap(
                                      spacing: 6,
                                      children: favs.map((f) => Chip(
                                        label: Text(f, style: const TextStyle(fontSize: 10)),
                                        backgroundColor: primaryBlue.withOpacity(0.1),
                                        side: BorderSide.none,
                                      )).toList(),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text("Jago di ${insight['strongest']}, butuh latihan di ${insight['weakest']}", style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () => _generateDetailedReport(context, data, insight),
                                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                                      label: const Text("Unduh Laporan Lengkap (AI)"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentOrange, foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 45),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    )
                                  ] else ...[
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      onPressed: () => _setActiveChild(user.uid, doc.id),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: primaryBlue),
                                        minimumSize: const Size(double.infinity, 40),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text("Pilih sebagai Aktif", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: primaryBlue)),
                                    )
                                  ]
                                ],
                              ),
                            );
                          }
                        );
                      },
                    );
                  }
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}