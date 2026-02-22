import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../features/quran/surah_list_screen.dart';
import '../../features/prayer_times/prayer_times_screen.dart';
import '../../features/tasbeeh/tasbeeh_screen.dart';
import '../../features/hadith/hadith_screen.dart';
import '../../features/more/more_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(
      label: 'Quran',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      gradient: [Color(0xFF0e7a6e), Color(0xFF065F52)],
    ),
    _TabItem(
      label: 'Prayers',
      icon: Icons.access_time_outlined,
      activeIcon: Icons.access_time_rounded,
      gradient: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    ),
    _TabItem(
      label: 'Tasbeeh',
      icon: Icons.grain_outlined,
      activeIcon: Icons.grain_rounded,
      gradient: [Color(0xFF0e7a6e), Color(0xFF065F52)],
    ),
    _TabItem(
      label: 'Hadith',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
      gradient: [Color(0xFF7B3FA0), Color(0xFF4A148C)],
    ),
    _TabItem(
      label: 'More',
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps_rounded,
      gradient: [Color(0xFFC8A951), Color(0xFFB8902A)],
    ),
  ];

  static const List<Widget> _screens = [
    SurahListScreen(),
    PrayerTimesScreen(),
    TasbeehScreen(),
    HadithScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNav(isDark),
    );
  }

  Widget _buildNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = i == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: 250.ms,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: 250.ms,
                          width: isActive ? 48 : 36,
                          height: isActive ? 48 : 36,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(colors: tab.gradient)
                                : null,
                            color: isActive ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(isActive ? 16 : 10),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color:
                                          tab.gradient.first.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            color: isActive
                                ? Colors.white
                                : (isDark ? Colors.grey[500] : Colors.grey[400]),
                            size: isActive ? 24 : 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive
                                ? tab.gradient.first
                                : (isDark ? Colors.grey[500] : Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final List<Color> gradient;
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.gradient,
  });
}
