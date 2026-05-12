import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_child_page.dart';

class RegisterParentPage extends StatefulWidget {
  const RegisterParentPage({super.key});

  @override
  State<RegisterParentPage> createState() => _RegisterParentPageState();
}

class _RegisterParentPageState extends State<RegisterParentPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  Future<void> _registerParent() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'role': 'ortu',
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterChildPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString(), style: GoogleFonts.quicksand()),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkBlueText),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'lib/assets/parent_owl.png', 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.family_restroom_rounded, size: 100, color: primaryBlue);
                  },
                ),
              ),
              
              // Judul
              Text(
                "Akun Orang Tua",
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: darkBlueText,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subjudul
              Text(
                "Buat akun untuk memantau perkembangan belajar anak.",
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),

              // Form Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.quicksand(color: primaryBlue, fontWeight: FontWeight.bold),
                  prefixIcon: Icon(Icons.email_outlined, color: primaryBlue),
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
                ),
              ),
              const SizedBox(height: 16),

              // Form Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: GoogleFonts.quicksand(color: primaryBlue, fontWeight: FontWeight.bold),
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryBlue),
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
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Lanjut
              ElevatedButton(
                onPressed: _registerParent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange, // Pakai warna oranye biar mencolok
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: accentOrange.withOpacity(0.4),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Daftar",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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