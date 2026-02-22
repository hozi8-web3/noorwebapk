import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme/app_theme.dart';
import '../../features/ramadan/ramadan_screen.dart';
import '../../features/names_99/names_99_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/zakat/zakat_screen.dart';
import '../../features/prophet_stories/prophet_stories_screen.dart';
import '../../features/calendar/islamic_calendar_screen.dart';
import '../../features/settings/bloc/settings_bloc.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final features = [
      _MoreItem('Ramadan', Icons.nightlight_rounded, const RamadanScreen(),
          const [Color(0xFF1565C0), Color(0xFF0D47A1)]),
      _MoreItem('99 Names', Icons.stars_rounded, const Names99Screen(),
          [AppColors.primary, AppColors.primaryDark]),
      _MoreItem('Qibla', Icons.explore_rounded, const QiblaScreen(),
          const [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
      _MoreItem('Zakat', Icons.monetization_on_outlined, const ZakatScreen(),
          const [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
      _MoreItem('Prophets', Icons.person_rounded, const ProphetStoriesScreen(),
          [AppColors.accent, const Color(0xFFB8902A)]),
      _MoreItem('Calendar', Icons.calendar_month_rounded,
          const IslamicCalendarScreen(),
          const [Color(0xFFC62828), Color(0xFFB71C1C)]),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('More'),
        actions: [
          // Dark mode toggle
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final isDarkMode =
                  state is SettingsLoaded ? state.isDarkMode : false;
              return IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () =>
                    context.read<SettingsBloc>().add(ToggleTheme()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, i) {
            final item = features[i];
            return _MoreCard(item: item, index: i)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 80 * i))
                .scale(begin: const Offset(0.9, 0.9));
          },
        ),
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final IconData icon;
  final Widget screen;
  final List<Color> gradient;
  const _MoreItem(this.title, this.icon, this.screen, this.gradient);
}

class _MoreCard extends StatelessWidget {
  final _MoreItem item;
  final int index;
  const _MoreCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screen),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 40),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
