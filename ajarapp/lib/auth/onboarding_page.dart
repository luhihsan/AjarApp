import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'landing_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final Color primaryBlue = const Color(0xFF67BEE0);
  final Color accentOrange = const Color(0xFFFF8E00);
  final Color darkBlueText = const Color(0xFF2C6C85);
  final Color bgColor = const Color(0xFFFDFDFD);

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Belajar Jadi Petualangan Seru!",
      "desc": "Kerjakan kuis asik dan kumpulkan XP untuk naik level layaknya seorang pahlawan.",
      "image": "lib/assets/onboard_1.png",
      "icon": "school",
    },
    {
      "title": "Guru AI Super Pintar",
      "desc": "Setiap jawaban esai dikoreksi otomatis. AI akan memberimu saran belajar yang personal.",
      "image": "lib/assets/onboard_2.png",
      "icon": "smart_toy",
    },
    {
      "title": "Pantau Perkembangan Anak",
      "desc": "Orang tua dapat mengunduh rapor digital dan mengetahui kelemahan materi secara instan.",
      "image": "lib/assets/onboard_3.png",
      "icon": "analytics",
    },
  ];

  Future<void> _selesaiOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
      );
    }
  }

  IconData _getFallbackIcon(String iconName) {
    switch (iconName) {
      case "school": return Icons.school_rounded;
      case "smart_toy": return Icons.smart_toy_rounded;
      case "analytics": return Icons.analytics_rounded;
      default: return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Lewati di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _selesaiOnboarding,
                child: Text("Lewati", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),

            // PageView untuk Swipe Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            _onboardingData[index]["image"]!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getFallbackIcon(_onboardingData[index]["icon"]!),
                              size: 150,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: darkBlueText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indikator Titik & Tombol Bawah
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Tombol Selanjutnya / Mulai
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == _onboardingData.length - 1) {
                        _selesaiOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex == _onboardingData.length - 1 ? accentOrange : primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentIndex == _onboardingData.length - 1 ? "Mulai Sekarang!" : "Selanjutnya",
                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentIndex == index ? accentOrange : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}