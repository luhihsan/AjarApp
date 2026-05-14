import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/landing_page.dart';
import '../auth/register_child_page.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF67BEE0);
    final Color accentOrange = const Color(0xFFFF8E00);
    final Color darkBlueText = const Color(0xFF2C6C85);
    final Color bgColor = const Color(0xFFFDFDFD);

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Sesi telah habis."));
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text("Profil Keluarga", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: darkBlueText)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INFO AKUN ORANG TUA
            Text("Akun Orang Tua", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.person_outline_rounded, color: primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email Terdaftar", style: GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(user.email ?? "Tidak ada email", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: darkBlueText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. DAFTAR ANAK (STREAM BUILDER)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Anak-anak Saya", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman Register Anak pakai mode "Tambah"
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterChildPage(uidOrtu: user.uid)));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: primaryBlue),
                        const SizedBox(width: 4),
                        Text("Tambah", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: primaryBlue)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // List Anak dari Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('children')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("Belum ada data anak.", style: GoogleFonts.quicksand(color: Colors.grey));
                }

                var childrenDocs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: childrenDocs.length,
                  itemBuilder: (context, index) {
                    var data = childrenDocs[index].data() as Map<String, dynamic>;
                    String nama = data['nama_panggilan'] ?? "Anak";
                    String kelas = data['kelas']?.toString() ?? "-";
                    int xp = data['xp'] ?? 0;
                    int level = (xp ~/ 100) + 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: accentOrange.withOpacity(0.1),
                            child: Text(nama[0].toUpperCase(), style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: accentOrange)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nama, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                                Text("Kelas $kelas SD  •  Lvl $level", style: GoogleFonts.quicksand(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          // Untuk MVP, anak pertama jadi yang aktif
                          if (index == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                              child: Text("Aktif", style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                            )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),

            // 3. TOMBOL LOGOUT
            Text("Sesi & Keamanan", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const LandingPage()), 
                    (route) => false
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: Text("Keluar dari Aplikasi", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }
}