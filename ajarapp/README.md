# 📚 AjarApp - Aplikasi Belajar Interaktif untuk Anak

**AjarApp** adalah aplikasi pembelajaran interaktif berbasis Flutter yang dirancang untuk membuat proses belajar anak menjadi menyenangkan dan engaging. Aplikasi ini menggabungkan teknologi AI (Gemini) untuk membuat kuis otomatis dan sistem gamifikasi untuk memotivasi anak belajar.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

---

## 🎯 Deskripsi Proyek

AjarApp adalah platform pembelajaran yang menargetkan anak-anak sekolah dasar dengan fitur-fitur modern:
- ✨ **Kuis Interaktif**: Dibuat secara otomatis menggunakan AI Gemini
- 🎮 **Sistem Gamifikasi**: Kumpulkan XP, naik level, dan pertahankan streak belajar
- 🤖 **Koreksi Otomatis**: AI mengevaluasi jawaban esai secara instan
- 📊 **Dashboard Orang Tua**: Monitor perkembangan belajar anak dengan laporan detail
- 📱 **Multi-platform**: Support iOS, Android, Web, macOS, Linux, Windows

---

## 📋 Fitur Utama

### 1. **Sistem Autentikasi**
- ✅ Registrasi orang tua dengan email dan password
- ✅ Google Sign-In untuk login cepat
- ✅ Validasi password dengan kriteria keamanan (min 8 karakter, uppercase, number)
- ✅ Onboarding screen untuk pengguna baru

### 2. **Manajemen Profil Anak**
- Orang tua dapat mendaftarkan multiple anak
- Setiap anak memiliki profil dengan:
  - Nama lengkap dan nama panggilan
  - Kelas (1-6)
  - Semester (Ganjil/Genap)
  - Mata pelajaran favorit

### 3. **Sistem Kuis Cerdas**
- **Konfigurasi Fleksibel**:
  - Pilih mata pelajaran (Matematika, Bahasa Indonesia, IPAS, dll)
  - Atur jumlah soal (1-50)
  - Pilih level kesulitan (Mudah, Sedang, Sulit)
  - Tentukan waktu pengerjaan
  - Pilih tipe soal: Pilihan Ganda atau Esai

- **Kuis Dinamis**:
  - Soal dibuat real-time menggunakan AI Gemini
  - Soal disesuaikan dengan kelas dan semester anak
  - Support multiple pilihan jawaban

### 4. **Gameplay Interaktif**
- Timer real-time untuk setiap kuis
- Interface intuitif untuk menjawab soal
- Navigasi soal dengan tombol Sebelumnya/Selanjutnya
- Peringatan jika mencoba keluar sebelum selesai

### 5. **Sistem Penilaian & Evaluasi**
- Koreksi otomatis menggunakan AI Gemini
- Feedback personal untuk setiap jawaban esai
- Saran belajar berdasarkan hasil kuis
- Penjelasan mendalam di halaman pembahasan

### 6. **Gamifikasi & Reward**
- 🏆 **Sistem XP**:
  - Dapatkan XP berdasarkan skor kuis
  - Multiplier untuk level kesulitan (Mudah: 1x, Sedang: 1.5x, Sulit: 2x)
  - Bonus XP untuk waktu terbatas
  
- 📈 **Sistem Level**:
  - XP 100 untuk Level 1
  - Setiap level membutuhkan XP lebih banyak
  - Visual progress bar menunjukkan kemajuan

- 🔥 **Streak System**:
  - Hitung konsistensi belajar harian
  - Reset jika tidak ada kuis dalam sehari
  - Motivasi anak untuk belajar rutin

### 7. **Dashboard & Analytics**
- Tampilkan level, XP, dan progress anak
- Statistik kuis (total kuis, rata-rata skor)
- Radar chart menunjukkan kekuatan/kelemahan per mata pelajaran
- Riwayat kuis dengan filter berdasarkan mata pelajaran
- Rekomendasi mata pelajaran yang perlu diperkuat

### 8. **Profile Tab - Fitur Orang Tua**
- Kelola multiple profil anak
- Tentukan anak aktif (yang sedang belajar)
- Unduh laporan pembelajaran dalam format PDF
- Logout dari aplikasi

### 9. **Laporan Digital PDF**
- Nama anak dan statistik umum
- Daftar mata pelajaran favorit
- Nilai rata-rata per mata pelajaran
- Mata pelajaran terkuat dan terlemah
- Rekomendasi belajar personal

---

## 🛠️ Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Frontend | Flutter, Dart |
| Backend | Firebase (Authentication, Firestore) |
| AI/ML | Google Generative AI (Gemini) |
| Database | Cloud Firestore |
| PDF Generation | Printing, PDF packages |
| State Management | Native StatefulWidget |
| Styling | Google Fonts |
| Environment | flutter_dotenv |

---

## 📁 Struktur Folder

```
lib/
├── main.dart                      # Entry point & route decider
├── auth/
│   ├── landing_page.dart         # Halaman login/register
│   ├── login_page.dart           # Form login
│   ├── register_parent_page.dart  # Registrasi orang tua
│   ├── register_child_page.dart   # Registrasi anak
│   └── onboarding_page.dart      # Tutorial awal
├── main_screen/
│   ├── main_screen.dart          # Bottom navigation
│   ├── dashboard_tab.dart        # Beranda & statistik
│   ├── quiz_tab.dart             # Daftar kuis
│   ├── profile_tab.dart          # Profil & settings
│   └── history_page.dart         # Riwayat kuis
├── quiz/
│   ├── quiz_config_page.dart     # Atur kuis
│   ├── quiz_play_page.dart       # Gameplay
│   ├── quiz_result_page.dart     # Hasil kuis
│   └── quiz_review_page.dart     # Pembahasan
├── models/
│   └── question_model.dart       # Model soal
├── services/
│   ├── gemini_service.dart       # API Gemini
│   ├── user_service.dart         # User & XP logic
│   └── auth_helper.dart          # Validator & handlers
├── utils/
│   └── auth_helper.dart          # Error handler & snackbar
└── assets/
    └── (logo, onboarding images)
```

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (versi terbaru)
- Dart SDK
- Android Studio / Xcode
- Firebase Project

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd ajarapp
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Firebase Configuration
1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Download `google-services.json` (Android) dan letakkan di `android/app/`
3. Setup Firebase di iOS jika diperlukan
4. Generate `firebase_options.dart` dengan Flutter CLI

### Step 4: Setup Environment Variables
Buat file `.env` di root project:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 5: Run Application
```bash
# Development
flutter run

# Production build
flutter build apk
flutter build ios
```

---

## 🔐 Firebase Setup

### Collections Structure:
```
users/
├── {parentUid}/
│   ├── email: string
│   ├── role: "parent"
│   ├── active_child_id: string (ID anak aktif)
│   ├── createdAt: timestamp
│   └── children/ (subcollection)
│       ├── {childId}/
│       │   ├── nama_lengkap: string
│       │   ├── nama_panggilan: string
│       │   ├── kelas: string
│       │   ├── semester: string
│       │   ├── mapel_fav: array
│       │   ├── total_xp: number
│       │   ├── createdAt: timestamp
│       │   └── quiz_results/ (subcollection)
│       │       ├── {resultId}/
│       │       │   ├── mapel: string
│       │       │   ├── score: number
│       │       │   ├── tanggal: timestamp
│       │       │   ├── soal_dijawab: number
│       │       │   ├── soal_benar: number
│       │       │   └── kesulitan: string
```

---

## 🎮 Cara Menggunakan

### Untuk Orang Tua:
1. **Register** dengan email dan password
2. **Onboarding** - pelajari fitur aplikasi
3. **Daftar Anak** - input data anak beserta mata pelajaran favorit
4. **Monitor Dashboard** - lihat progress belajar anak real-time
5. **Unduh Laporan** - dapatkan PDF report pembelajaran anak

### Untuk Anak:
1. **Pilih Mata Pelajaran** di Quiz Tab
2. **Atur Konfigurasi Kuis** (jumlah soal, kesulitan, waktu)
3. **Jawab Soal** - mode pilihan ganda atau esai
4. **Lihat Hasil** - score, evaluasi AI, dan feedback
5. **Review Pembahasan** - pahami soal yang salah
6. **Kumpulkan XP** - naik level dan pertahankan streak

---

## 📊 Sistem XP & Level

### Perhitungan XP:
```
Base XP = (Score / 100) × (Jumlah Soal × 10)
Difficulty Multiplier = 1.0 (Mudah), 1.5 (Sedang), 2.0 (Sulit)
Time Multiplier = 1.5 (≤5 min), 1.2 (≤10 min), 1.0 (≤15 min), 0.8 (>15 min)

Final XP = Base XP × Difficulty × Time Multiplier
```

### Level Progression:
- **Level 1**: 0-100 XP
- **Level 2**: 100-250 XP
- **Level 3**: 250-450 XP
- (Setiap level naik 150 XP)

---

## 🤖 Integrasi AI Gemini

### Fitur AI:
1. **Generasi Kuis Otomatis**
   - Input: Mata pelajaran, jumlah soal, kesulitan, kelas, semester
   - Output: JSON array berisi soal, opsi, jawaban, penjelasan

2. **Koreksi Esai Otomatis**
   - Evaluasi jawaban open-ended
   - Memberikan skor otomatis
   - Feedback pembelajaran yang personal

3. **Evaluasi Pembelajaran**
   - Analisis hasil kuis anak
   - Saran motivasi dan rekomendasi belajar
   - Format mudah dipahami anak SD

---

## 🐛 Error Handling

Aplikasi memiliki error handling untuk:
- ❌ Network failures
- ❌ Invalid credentials
- ❌ Firestore permissions
- ❌ Gemini API errors
- ❌ Form validation

Semua error ditampilkan dalam format snackbar yang user-friendly.

---

## 📝 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.1.5
  google_generative_ai: ^0.3.0
  flutter_dotenv: ^5.1.0
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
  pdf: ^3.10.6
  printing: ^5.11.0
  google_maps_flutter: (optional untuk feature lokasi)
```

---

## 🔒 Security Best Practices

✅ API key disimpan di `.env` (jangan commit ke git)
✅ Firebase Security Rules melindungi data user
✅ Password validation dengan kriteria keamanan
✅ Email verification (opsional untuk production)
✅ Input sanitization di form validation

---

## 📚 Pembelajaran & Referensi

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Setup](https://firebase.flutter.dev/)
- [Google Generative AI API](https://ai.google.dev/)
- [Dart Documentation](https://dart.dev/guides)

---

## 👨‍💻 Development Tips

### Testing Locally:
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Web version
flutter run -d web-server
```

### Common Issues:
- **Firebase initialization error**: Pastikan `google-services.json` sudah benar
- **Gemini API error**: Cek validitas API key di `.env`
- **Build error**: Run `flutter clean` kemudian `flutter pub get`

---

## 📄 License

Proyek ini adalah proprietary software. Semua hak reserved.

---

## 👥 Contributors

- **Project Owner**: Galuh
- **Development**: Flutter Team

---

## 📞 Support & Contact

Untuk pertanyaan atau bug report, hubungi tim development.

---

**Last Updated**: Juni 2026
**Version**: 1.0.0
**Status**: Active Development 🚀
