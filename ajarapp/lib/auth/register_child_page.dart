import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  
  String? _kelas;
  String? _semester;
  String? _mapelFav;

  final List<String> _kelasList = ['1', '2', '3', '4', '5', '6'];
  final List<String> _semesterList = ['Ganjil', 'Genap'];
  final List<String> _mapelList = ['Matematika', 'Bahasa Indonesia', 'Bahasa Inggris', 'IPA', 'IPS'];

  Future<void> _simpanDataAnak() async {
    if (_namaController.text.isEmpty || _kelas == null || _semester == null || _mapelFav == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi semua data!")));
      return;
    }

    try {
      String uidOrtu = FirebaseAuth.instance.currentUser!.uid;

      // Simpan di sub-collection 'children' milik Ortu tersebut
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uidOrtu)
          .collection('children')
          .add({
        'nama': _namaController.text.trim(),
        'usia': int.tryParse(_usiaController.text.trim()) ?? 0,
        'kelas': _kelas,
        'semester': _semester,
        'mapel_fav': _mapelFav,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data anak berhasil disimpan!")));
      // Nanti arahkan ke Dashboard/Home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Anak")),
      body: SingleChildScrollView( // Biar ga error overflow kalau keyboard muncul
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama Anak")),
            TextField(controller: _usiaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Usia")),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Kelas (SD)"),
              value: _kelas,
              items: _kelasList.map((k) => DropdownMenuItem(value: k, child: Text("Kelas $k"))).toList(),
              onChanged: (val) => setState(() => _kelas = val),
            ),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Semester"),
              value: _semester,
              items: _semesterList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _semester = val),
            ),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Mata Pelajaran Favorit"),
              value: _mapelFav,
              items: _mapelList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _mapelFav = val),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _simpanDataAnak, child: const Text("Selesai & Masuk Beranda")),
            ),
          ],
        ),
      ),
    );
  }
}