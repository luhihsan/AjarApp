import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_child_page.dart';

class RegisterParentPage extends StatefulWidget {
  const RegisterParentPage({super.key});

  @override
  State<RegisterParentPage> createState() => _RegisterParentPageState();
}

class _RegisterParentPageState extends State<RegisterParentPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _registerParent() async {
    try {
      // 1. Daftar ke Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Simpan ke Firestore (Koleksi users)
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'role': 'ortu',
        'createdAt': DateTime.now(),
      });

      // 3. Pindah ke halaman daftar anak (pushReplacement biar ga bisa di-back ke register ortu)
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterChildPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Ortu")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _registerParent, child: const Text("Lanjut Data Anak ->")),
            ),
          ],
        ),
      ),
    );
  }
}