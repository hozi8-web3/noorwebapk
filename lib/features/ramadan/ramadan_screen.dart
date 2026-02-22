import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../app/theme/app_theme.dart';
import '../../data/models/prayer_time_model.dart';
import '../prayer_times/bloc/prayer_times_bloc.dart';

/// Ramadan screen reads Sehri (Fajr) and Iftar (Maghrib) from the
/// already-loaded PrayerTimesBloc state — no extra API call needed.
class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _timeUntil(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return Duration.zero;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final target =
        DateTime(_now.year, _now.month, _now.day, h, m);
    final diff = target.difference(_now);
    return diff.isNegative ? diff + const Duration(days: 1) : diff;
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          PrayerTimeModel? pt;
          bool isGps = false;
          if (state is PrayerTimesLoaded) {
            pt = state.prayerTimes;
            isGps = state.isGps;
          }
          return _buildBody(context, pt, isGps);
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, PrayerTimeModel? pt, bool isGps) {
    final sehri = pt?.fajr ?? '04:30';   // Fajr = Sehri end
    final iftar = pt?.maghrib ?? '18:30'; // Maghrib = Iftar
    final sehriLeft = _timeUntil(sehri);
    final iftarLeft = _timeUntil(iftar);
    final city = pt?.city ?? 'Default';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: _buildHeader(city, isGps)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // No prayer times message if not loaded
              if (pt == null) ...[
                const SizedBox(height: 16),
                _buildNoPrayerBanner(context),
              ],
              const SizedBox(height: 16),
              _buildCountdown(
                title: 'Sehri Time Ends',
                subtitle: 'Fajr Adhan at $sehri',
                icon: Icons.wb_twilight_rounded,
                countdown: _fmt(sehriLeft),
                colors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 12),
              _buildCountdown(
                title: 'Iftar Time',
                subtitle: 'Maghrib Adhan at $iftar',
                icon: Icons.nightlight_rounded,
                countdown: _fmt(iftarLeft),
                colors: const [Color(0xFFC8A951), Color(0xFFFF8F00)],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              _buildDuas().animate().fadeIn(delay: 300.ms),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String city, bool isGps) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E2A), Color(0xFF1A2456)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ramadan',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13,
                          letterSpacing: 2)),
                  Row(
                    children: [
                      Icon(isGps ? Icons.gps_fixed : Icons.location_on,
                          color: Colors.white54, size: 13),
                      const SizedBox(width: 4),
                      Text(city,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'رَمَضَان',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 56, color: const Color(0xFFC8A951),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'The Month of Mercy',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPrayerBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Go to Prayers tab to load your location-based Sehri & Iftar times.',
              style: const TextStyle(color: Colors.amber, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown({
    required String title,
    required String subtitle,
    required IconData icon,
    required String countdown,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  countdown,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuas() {
    final duas = [
      {
        'label': 'Dua at Sehri end (Fajr)',
        'arabic':
            'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ',
        'meaning':
            'I intend to keep the fast tomorrow in the month of Ramadan.',
      },
      {
        'label': 'Dua to break the fast (Iftar)',
        'arabic':
            'اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
        'meaning':
            'O Allah! I fasted for You, believed in You, put my trust in You, and broke my fast with Your provision.',
      },
      {
        'label': 'Dua of Night of Power (Laylatul Qadr)',
        'arabic':
            'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
        'meaning':
            'O Allah, You are Most Forgiving and You love forgiveness, so forgive me.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ramadan Duas',
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...duas.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFC8A951).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(d['label']!,
                      style: const TextStyle(
                          color: Color(0xFFC8A951),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Text(
                    d['arabic']!,
                    style: GoogleFonts.scheherazadeNew(
                        color: Colors.white, fontSize: 22, height: 1.8),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(d['meaning']!,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13, height: 1.6)),
                ],
              ),
            )),
      ],
    );
  }
}
