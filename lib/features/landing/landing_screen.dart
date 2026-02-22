import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../data/storage/storage_service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_FeatureSlide> _slides = const [
    _FeatureSlide(
      icon: Icons.menu_book_rounded,
      title: 'Quran Majeed',
      subtitle: 'Read the Holy Quran with Urdu translation and bookmarks',
      gradient: [Color(0xFF0e7a6e), Color(0xFF0a5e55)],
    ),
    _FeatureSlide(
      icon: Icons.access_time_rounded,
      title: 'Prayer Times',
      subtitle: 'Accurate daily prayer times for your city with countdown',
      gradient: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    ),
    _FeatureSlide(
      icon: Icons.grain_rounded,
      title: 'Digital Tasbeeh',
      subtitle: 'Count your dhikr easily with beautiful presets',
      gradient: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
    ),
    _FeatureSlide(
      icon: Icons.auto_stories_rounded,
      title: 'Hadith & Stories',
      subtitle: 'Authentic hadiths and inspiring Prophet stories',
      gradient: [Color(0xFFC8A951), Color(0xFFB8902A)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen pager
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _SlideWidget(slide: _slides[i]),
          ),

          // Top overlay: logo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'NoorWeb',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms),
            ),
          ),

          // Bottom: dots + button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: 400.ms,
                              curve: Curves.easeInOut,
                            );
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await StorageService(prefs).completeFirstLaunch();
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage < _slides.length - 1
                              ? 'Next'
                              : 'Get Started',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_currentPage < _slides.length - 1) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await StorageService(prefs).completeFirstLaunch();
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  const _FeatureSlide(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.gradient});
}

class _SlideWidget extends StatelessWidget {
  final _FeatureSlide slide;
  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradient,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 60, color: Colors.white),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              slide.subtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white.withOpacity(0.85),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
