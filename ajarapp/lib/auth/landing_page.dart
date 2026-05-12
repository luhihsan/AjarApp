import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'register_parent_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  final Color primaryBlue = const Color(0xFF67BEE0); 
  final Color accentOrange = const Color(0xFFFF8E00); 
  final Color darkBlueText = const Color(0xFF2C6C85); 
  final Color bgColor = const Color(0xFFFDFDFD); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/logo.png',
                  height: 180, 
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                
                // Judul Aplikasi
                Text(
                  "Ajar",
                  style: GoogleFonts.nunito(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: accentOrange, 
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subjudul
                Text(
                  "Teman Belajar Anak Anda",
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkBlueText, 
                  ),
                ),
                const SizedBox(height: 60),

                // Tombol Masuk (Primary)
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
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
                    "Masuk",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Daftar (Secondary - Outlined)
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterParentPage())),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accentOrange, width: 2.5), // Outline oranye
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Daftar Akun Baru",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}