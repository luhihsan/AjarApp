import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email wajib diisi.";
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return "Format email tidak valid.";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password wajib diisi.";
  
    if (value.length < 8 ||
        !value.contains(RegExp(r'[A-Z]')) ||
        !value.contains(RegExp(r'[0-9]')) ||
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Kriteria keamanan password belum terpenuhi.";
    }
    return null;
  }
}

class AuthExceptionHandler {
  static String getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email ini sudah terdaftar di sistem. Silakan gunakan email lain atau coba masuk.";
      case 'user-not-found':
        return "Akun dengan email tersebut tidak ditemukan.";
      case 'wrong-password':
      case 'invalid-credential':
        return "Email atau password yang dimasukkan tidak sesuai.";
      case 'network-request-failed':
        return "Gagal terhubung ke server. Periksa koneksi internet Anda.";
      default:
        return "Terjadi kesalahan otentikasi: ${e.message}";
    }
  }
}

class CustomSnackBar {
  static void show(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.warning_rounded : Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message, 
                style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.w600)
              )
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        elevation: 4,
      ),
    );
  }
}