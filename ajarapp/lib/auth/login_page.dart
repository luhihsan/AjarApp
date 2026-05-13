import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'register_parent_page.dart';
import 'package:ajarapp/utils/auth_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Key untuk memicu validasi Form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Palet Warna Senada
  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  Future<void> _login() async {
    // 1. CEK VALIDASI FORM (Cegah hit Firebase kalau form kosong/salah format)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // 2. Eksekusi Login ke Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Jika Berhasil
      if (mounted) {
        CustomSnackBar.show(context, "Selamat datang kembali!", isError: false);
        // TODO: Arahkan ke Dashboard
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } on FirebaseAuthException catch (e) {
      // Tangkap dan terjemahkan pesan error Firebase
      String errorMessage = AuthExceptionHandler.getMessage(e);
      CustomSnackBar.show(context, errorMessage);
    } catch (e) {
      CustomSnackBar.show(context, "Error: $e");
    }
  }

  // Helper untuk styling input text
  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.quicksand(
          color: primaryBlue, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: primaryBlue),
      filled: true,
      fillColor: Colors.blue.shade50.withOpacity(0.5),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryBlue, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: darkBlueText)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // BUNGKUS DENGAN FORM
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Ikon Login (Bisa diganti pakai gambar kalau punya asetnya)
                Icon(Icons.lock_person_rounded, size: 100, color: accentOrange),
                const SizedBox(height: 24),

                // Judul
                Text("Masuk",
                    style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: darkBlueText)),
                const SizedBox(height: 8),
                Text(
                  "Selamat datang kembali di Ajar App!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),

                // Form Email
                TextFormField(
                  controller: _emailController,
                  validator: AppValidator
                      .validateEmail, // Panggil validasi format email
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600, color: darkBlueText),
                  decoration: _customInputDecoration(
                      "Email Ortu", Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // Form Password
                TextFormField(
                  controller: _passwordController,
                  // Validasi simpel: cuma ngecek kosong atau nggak
                  validator: (value) => value == null || value.isEmpty
                      ? "Password tidak boleh kosong ya"
                      : null,
                  obscureText: true,
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600, color: darkBlueText),
                  decoration: _customInputDecoration(
                      "Password", Icons.lock_outline_rounded),
                ),
                const SizedBox(height: 40),

                // Tombol Masuk
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 4,
                    shadowColor: primaryBlue.withOpacity(0.4),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("Masuk",
                      style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 16),

                // Tombol Alternatif kalau belum punya akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun? ",
                        style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterParentPage())),
                      child: Text("Daftar di sini",
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              color: accentOrange)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
