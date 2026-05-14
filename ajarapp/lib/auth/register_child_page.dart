import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main_screen/main_screen.dart'; 

class RegisterChildPage extends StatefulWidget {
  // Menerima UID Ortu dari halaman Register Ortu / Halaman Profil
  final String uidOrtu; 
  
  const RegisterChildPage({super.key, required this.uidOrtu});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _namaLengkapController = TextEditingController();
  final _namaPanggilanController = TextEditingController();
  
  String? _kelas;
  String? _semester;
  
  final List<String> _mapelFav = [];

  final List<String> _kelasList = ['1', '2', '3', '4', '5', '6'];
  final List<String> _semesterList = ['Ganjil', 'Genap'];
  
  final List<String> _mapelList = [
    'Matematika', 'Bahasa Indonesia', 'IPAS', 
    'Pend. Pancasila', 'Bahasa Inggris', 'Seni Budaya', 'PJOK'
  ];

  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  Future<void> _simpanDataAnak() async {
    if (_namaLengkapController.text.isEmpty || _namaPanggilanController.text.isEmpty || 
        _kelas == null || _semester == null || _mapelFav.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Harap isi semua data & pilih minimal 1 mapel!", style: GoogleFonts.quicksand()),
        backgroundColor: accentOrange,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menyimpan data anak ke sub-collection 'children' di bawah dokumen Ortu
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uidOrtu) 
          .collection('children')
          .add({
        'nama_lengkap': _namaLengkapController.text.trim(),
        'nama_panggilan': _namaPanggilanController.text.trim(),
        'kelas': _kelas,
        'semester': _semester,
        'mapel_fav': _mapelFav,
        'xp': 0, // Set XP awal ke 0
        'last_updated_semester': DateTime.now(),
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Berhasil!", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.green)),
            content: Text("Data profil anak berhasil disimpan. Mau nambah data anak lain atau langsung mulai belajar?", style: GoogleFonts.quicksand()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  // Refresh halaman dengan form kosong untuk nambah anak lagi
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => RegisterChildPage(uidOrtu: widget.uidOrtu))
                  );
                },
                child: Text("Tambah Anak Lain", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Langsung masuk ke Dashboard
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                child: Text("Mulai Belajar", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _tambahMapelCustom() async {
    String newMapel = "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Tambah Mata Pelajaran", style: GoogleFonts.nunito(color: darkBlueText, fontWeight: FontWeight.bold)),
          content: TextField(
            autofocus: true,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
            decoration: InputDecoration(
              hintText: "Misal: Bahasa Jawa, Coding, dll",
              hintStyle: GoogleFonts.quicksand(color: Colors.grey),
              filled: true,
              fillColor: Colors.blue.shade50.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (value) => newMapel = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.nunito(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newMapel.trim().isNotEmpty) {
                  setState(() {
                    _mapelList.add(newMapel.trim());
                    _mapelFav.add(newMapel.trim()); 
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Tambah", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Image.asset(
                    'lib/assets/baby_owl.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.face_retouching_natural_rounded, size: 90, color: accentOrange),
                  ),
                ),
              ),
              
              Center(
                child: Text(
                  "Satu langkah lagi!",
                  style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: darkBlueText),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Biar kuisnya pas, isi data anak di bawah ini ya.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
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
              const SizedBox(height: 24),

              Text(
                "Mata Pelajaran Favorit",
                style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ..._mapelList.map((mapel) {
                    final isSelected = _mapelFav.contains(mapel);
                    return FilterChip(
                      label: Text(mapel, style: GoogleFonts.quicksand(fontWeight: FontWeight.w600)),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : darkBlueText),
                      selected: isSelected,
                      selectedColor: accentOrange,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.blue.shade50.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: isSelected ? accentOrange : Colors.transparent),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _mapelFav.add(mapel);
                          } else {
                            _mapelFav.remove(mapel);
                          }
                        });
                      },
                    );
                  }).toList(),
                  
                  ActionChip(
                    label: Text("+ Tambah", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: primaryBlue)),
                    backgroundColor: bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: primaryBlue, width: 2, style: BorderStyle.solid),
                    onPressed: _tambahMapelCustom,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              _isLoading 
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : ElevatedButton(
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