import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // IMPORT UNTUK PLATFORM EXCEPTION
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart'; 

import 'register_child_page.dart';
import 'package:ajarapp/utils/auth_helper.dart';

class RegisterParentPage extends StatefulWidget {
  const RegisterParentPage({super.key});

  @override
  State<RegisterParentPage> createState() => _RegisterParentPageState();
}

class _RegisterParentPageState extends State<RegisterParentPage> {
  final _formKey = GlobalKey<FormState>(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  Future<void> _registerParent() async {
    if (!_formKey.currentState!.validate()) return; 

    setState(() => _isLoading = true);

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
        CustomSnackBar.show(context, "Akun berhasil dibuat!", isError: false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegisterChildPage(uidOrtu: userCredential.user!.uid)));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = AuthExceptionHandler.getMessage(e);
      CustomSnackBar.show(context, errorMessage);
    } catch (e) {
      CustomSnackBar.show(context, "Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      
      final googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'role': 'ortu',
          'createdAt': DateTime.now(),
        });
      }

      if (mounted) {
        CustomSnackBar.show(context, "Berhasil masuk dengan Google!", isError: false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegisterChildPage(uidOrtu: userCredential.user!.uid)));
      }
    } on PlatformException catch (e) {
      // LOGIC BARU: Abaikan kalau user cuma close popup
      if (e.code != 'sign_in_canceled' && e.code != 'CANCELED') {
        if (mounted) CustomSnackBar.show(context, "Gagal daftar Google: ${e.message}");
      }
    } catch (e) {
      // Penjagaan ekstra
      if (!e.toString().contains('sign_in_canceled') && !e.toString().contains('canceled by user')) {
        if (mounted) CustomSnackBar.show(context, "Terjadi kesalahan: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _customInputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.quicksand(color: primaryBlue, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: primaryBlue),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.blue.shade50.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryBlue, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: bgColor, elevation: 0, iconTheme: IconThemeData(color: darkBlueText)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Image.asset(
                    'lib/assets/parent_owl.png', 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.family_restroom_rounded, size: 100, color: primaryBlue),
                  ),
                ),
                Text("Akun Orang Tua", style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: darkBlueText)),
                const SizedBox(height: 8),
                Text("Buat akun untuk memantau perkembangan belajar anak.", textAlign: TextAlign.center, style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  validator: AppValidator.validateEmail, 
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                  decoration: _customInputDecoration("Email", Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  validator: AppValidator.validatePassword, 
                  obscureText: _obscurePassword, 
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: darkBlueText),
                  decoration: _customInputDecoration(
                    "Password", 
                    Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: primaryBlue),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ).copyWith(
                    helperText: "Min. 8 karakter, mencakup huruf kapital dan angka.",
                    helperMaxLines: 2,
                    helperStyle: GoogleFonts.quicksand(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 40),

                _isLoading 
                  ? CircularProgressIndicator(color: accentOrange)
                  : ElevatedButton(
                      onPressed: _registerParent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: accentOrange.withOpacity(0.4),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("Lanjut Data Anak", style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("ATAU", style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1.5)),
                  ],
                ),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signUpWithGoogle,
                   icon: Image.asset("lib/assets/logo_google.png", height: 24),
                  label: Text("Daftar dengan Google", style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlueText)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: Colors.grey.shade300, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}