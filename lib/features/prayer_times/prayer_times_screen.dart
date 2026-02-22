import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../app/theme/app_theme.dart';
import '../prayer_times/bloc/prayer_times_bloc.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> 
    with AutomaticKeepAliveClientMixin {
  Timer? _timer;
  Duration _countdown = Duration.zero;
  String _nextName = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<PrayerTimesBloc>().add(LoadPrayerTimesByGPS());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final state = context.read<PrayerTimesBloc>().state;
    if (state is! PrayerTimesLoaded) return;
    final now = DateTime.now();
    for (final p in state.prayerTimes.prayers) {
      if (p['name'] == 'Sunrise') continue;
      final parts = p['time']!.split(':');
      final t = DateTime(now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]));
      if (t.isAfter(now)) {
        if (mounted) setState(() {
          _countdown = t.difference(now);
          _nextName = p['name']!;
        });
        return;
      }
    }
    
    // If all prayers today have passed, calculate until tomorrow's Fajr
    final fajrStr = state.prayerTimes.fajr;
    final fajrParts = fajrStr.split(':');
    if (fajrParts.length >= 2) {
      final tomorrowFajr = DateTime(now.year, now.month, now.day + 1,
          int.parse(fajrParts[0]), int.parse(fajrParts[1]));
      if (mounted) setState(() {
        _countdown = tomorrowFajr.difference(now);
        _nextName = 'Fajr';
      });
    } else {
      if (mounted) setState(() { _countdown = Duration.zero; _nextName = 'Fajr'; });
    }
  }

  String _fmt(Duration d) =>
      '${d.inHours.toString().padLeft(2,'0')}:'
      '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:'
      '${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PrayerTimesBloc, PrayerTimesState>(
        listener: (context, state) {
          if (state is PrayerTimesLoaded) _tick();
        },
        builder: (context, state) {
          if (state is PrayerTimesLoading || state is PrayerTimesGpsLoading) {
            return _LoadingView(isGps: state is PrayerTimesGpsLoading);
          }
          if (state is PrayerTimesGpsPermissionDenied) {
            return _PermissionView(onFallback: () =>
                context.read<PrayerTimesBloc>().add(LoadPrayerTimes()));
          }
          if (state is PrayerTimesError) {
            return _ErrorView(message: state.message, onRetry: () =>
                context.read<PrayerTimesBloc>().add(LoadPrayerTimesByGPS()));
          }
          if (state is PrayerTimesLoaded) {
            return _MainView(
              state: state,
              countdown: _countdown,
              nextName: _nextName,
              countdownString: _fmt(_countdown),
              onGps: () => context.read<PrayerTimesBloc>().add(LoadPrayerTimesByGPS()),
              onCity: () => _showCityDialog(context),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCityDialog(BuildContext context) {
    final cityC = TextEditingController();
    final countryC = TextEditingController(text: 'PK');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cityC,
                decoration: const InputDecoration(labelText: 'City', hintText: 'e.g. Islamabad')),
            const SizedBox(height: 10),
            TextField(controller: countryC,
                decoration: const InputDecoration(labelText: 'Country Code', hintText: 'PK')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (cityC.text.isNotEmpty) {
                context.read<PrayerTimesBloc>().add(ChangeCity(cityC.text, countryC.text));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main loaded view
// ─────────────────────────────────────────────────────────────────────────────
class _MainView extends StatelessWidget {
  final PrayerTimesLoaded state;
  final Duration countdown;
  final String nextName;
  final String countdownString;
  final VoidCallback onGps;
  final VoidCallback onCity;

  const _MainView({
    required this.state,
    required this.countdown,
    required this.nextName,
    required this.countdownString,
    required this.onGps,
    required this.onCity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _Header(
          state: state,
          countdownString: countdownString,
          nextName: nextName,
          onGps: onGps,
          onCity: onCity,
        )),
        if (state.errorMessage != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _InfoBanner(message: state.errorMessage!),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final p = state.prayerTimes.prayers[i];
                final isNext = p['name'] == nextName;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PrayerCard(
                    name: p['name']!,
                    time: p['time']!,
                    icon: _icon(p['name']!),
                    isNext: isNext,
                    isDark: isDark,
                  ).animate().fadeIn(delay: Duration(milliseconds: 60 * i))
                    .slideX(begin: 0.05, duration: 400.ms),
                );
              },
              childCount: state.prayerTimes.prayers.length,
            ),
          ),
        ),
      ],
    );
  }

  IconData _icon(String name) {
    switch (name) {
      case 'Fajr': return Icons.wb_twilight_rounded;
      case 'Sunrise': return Icons.wb_sunny_outlined;
      case 'Dhuhr': return Icons.wb_sunny_rounded;
      case 'Asr': return Icons.filter_drama_rounded;
      case 'Maghrib': return Icons.nightlight_round;
      case 'Isha': return Icons.bedtime_rounded;
      default: return Icons.access_time_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final PrayerTimesLoaded state;
  final String countdownString;
  final String nextName;
  final VoidCallback onGps;
  final VoidCallback onCity;

  const _Header({
    required this.state,
    required this.countdownString,
    required this.nextName,
    required this.onGps,
    required this.onCity,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D6B62), Color(0xFF0A4F48), Color(0xFF063B35)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top actions row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prayer Times',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5)),
                        Text(today,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                  // GPS button
                  _HeaderBtn(
                    icon: Icons.my_location_rounded,
                    onTap: onGps,
                    tooltip: 'Use GPS',
                  ),
                  _HeaderBtn(
                    icon: Icons.tune_rounded,
                    onTap: onCity,
                    tooltip: 'Change city',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // City / location pill
              GestureDetector(
                onTap: onCity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isGps ? Icons.gps_fixed_rounded : Icons.location_city_rounded,
                        color: const Color(0xFFC8A951),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          state.cityName,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (state.isGps) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8A951).withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('LIVE',
                              style: TextStyle(
                                  color: Color(0xFFC8A951),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Countdown section
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFFC8A951), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text('Next: $nextName',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14,
                                letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      countdownString,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(state.prayerTimes.date,
                        style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _HeaderBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Prayer Card
// ─────────────────────────────────────────────────────────────────────────────
class _PrayerCard extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;
  final bool isNext;
  final bool isDark;

  const _PrayerCard({
    required this.name,
    required this.time,
    required this.icon,
    required this.isNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: isNext
            ? const LinearGradient(
                colors: [Color(0xFF0D6B62), Color(0xFF0A4F48)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isNext ? null : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isNext
                ? AppColors.primary.withOpacity(0.3)
                : Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: isNext ? 20 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isNext
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: isNext ? Colors.white : AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          // Name column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isNext ? Colors.white : null,
                    )),
                if (isNext)
                  Text('Upcoming prayer',
                      style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(time),
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.white : AppColors.primary),
              ),
              Text(
                _amPm(time),
                style: TextStyle(
                    fontSize: 11,
                    color: isNext ? Colors.white60 : Colors.grey[400],
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // "04:25" → "04:25" and "AM"
  String _formatTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${h12.toString().padLeft(2, '0')}:$m';
  }

  String _amPm(String t) {
    final h = int.tryParse(t.split(':').first) ?? 0;
    return h < 12 ? 'AM' : 'PM';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility widgets for loading/error/permission views
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message,
              style: const TextStyle(color: Colors.orange, fontSize: 12))),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final bool isGps;
  const _LoadingView({required this.isGps});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D6B62), Color(0xFF063B35)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(isGps ? '📍 Getting your location...' : 'Loading prayer times...',
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  final VoidCallback onFallback;
  const _PermissionView({required this.onFallback});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded, size: 70, color: AppColors.primary),
              const SizedBox(height: 20),
              Text('Location permission denied',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Please allow location access for accurate times.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onFallback,
                icon: const Icon(Icons.location_city),
                label: const Text('Use Default City'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 70, color: Colors.grey),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
