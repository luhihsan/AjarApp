import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _namaLengkapController = TextEditingController();
  final _namaPanggilanController = TextEditingController();
  
  String? _kelas;
  String? _semester;
  String? _mapelFav;

  final List<String> _kelasList = ['1', '2', '3', '4', '5', '6'];
  final List<String> _semesterList = ['Ganjil', 'Genap'];
  final List<String> _mapelList = ['Matematika', 'Bahasa Indonesia', 'Bahasa Inggris', 'IPA', 'IPS', 'PPKn'];

  // Palet Warna
  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  Future<void> _simpanDataAnak() async {
    // Validasi form tanpa kurikulum
    if (_namaLengkapController.text.isEmpty || _namaPanggilanController.text.isEmpty || 
        _kelas == null || _semester == null || _mapelFav == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Harap isi semua data ya!", style: GoogleFonts.quicksand()),
        backgroundColor: accentOrange,
      ));
      return;
    }

    try {
      String uidOrtu = FirebaseAuth.instance.currentUser!.uid;

      // Simpan data tanpa kurikulum
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uidOrtu)
          .collection('children')
          .add({
        'nama_lengkap': _namaLengkapController.text.trim(),
        'nama_panggilan': _namaPanggilanController.text.trim(),
        'kelas': _kelas,
        'semester': _semester,
        'mapel_fav': _mapelFav,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Hore! Profil anak berhasil dibuat!", style: GoogleFonts.quicksand()),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.quicksand(color: primaryBlue, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: primaryBlue),
      filled: true,
      fillColor: Colors.blue.shade50.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkBlueText),
        title: Text(
          "Profil Jagoan Kecil", 
          style: GoogleFonts.nunito(color: darkBlueText, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'lib/assets/baby_owl.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.face_retouching_natural_rounded, size: 90, color: accentOrange);
                  },
                ),
              ),
              
              Text(
                "Satu langkah lagi!",
                style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: darkBlueText),
              ),
              const SizedBox(height: 8),
              Text(
                "Biar kuisnya pas, isi data anak di bawah ini ya.",
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _namaLengkapController,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                decoration: _customInputDecoration("Nama Lengkap", Icons.person_outline),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _namaPanggilanController,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                decoration: _customInputDecoration("Nama Panggilan", Icons.sentiment_satisfied_alt_rounded),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _customInputDecoration("Kelas (SD)", Icons.school_outlined),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                      value: _kelas,
                      items: _kelasList.map((k) => DropdownMenuItem(value: k, child: Text("Kelas $k"))).toList(),
                      onChanged: (val) => setState(() => _kelas = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _customInputDecoration("Semester", Icons.calendar_today_outlined),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                      value: _semester,
                      items: _semesterList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _semester = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: _customInputDecoration("Mata Pelajaran Favorit", Icons.star_border_rounded),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                value: _mapelFav,
                items: _mapelList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => _mapelFav = val),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _simpanDataAnak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: primaryBlue.withOpacity(0.4),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Mulai Petualangan Belajar!",
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}