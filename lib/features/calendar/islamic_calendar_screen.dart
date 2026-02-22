import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;
import '../../app/theme/app_theme.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});
  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  // Region definitions: label, adjustment used in gToH
  static const List<_Region> _regions = [
    _Region('Global', '🌍', 0, 'Astronomical calculation'),
    _Region('Saudi Arabia', '🇸🇦', 0, 'Umm al-Qura calendar'),
    _Region('Pakistan', '🇵🇰', 1, 'Moon sighting (+1 day)'),
    _Region('India', '🇮🇳', 1, 'Moon sighting (+1 day)'),
    _Region('Turkey', '🇹🇷', -1, 'Diyanet (-1 day)'),
  ];

  int _regionIndex = 0;
  DateTime _selectedDate = DateTime.now();
  _HijriResult? _todayHijri;
  _HijriResult? _selectedHijri;
  bool _loading = true;
  bool _converting = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.aladhan.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    setState(() => _loading = true);
    try {
      final h = await _convertDate(DateTime.now(), _regions[_regionIndex].adjustment);
      if (mounted) setState(() { _todayHijri = h; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _convertSelectedDate() async {
    setState(() => _converting = true);
    try {
      final h = await _convertDate(_selectedDate, _regions[_regionIndex].adjustment);
      if (mounted) setState(() { _selectedHijri = h; _converting = false; });
    } catch (_) {
      if (mounted) setState(() => _converting = false);
    }
  }

  Future<_HijriResult> _convertDate(DateTime d, int adjustment) async {
    final dateStr = intl.DateFormat('dd-MM-yyyy').format(d);
    final resp = await _dio.get('/gToH/$dateStr',
        queryParameters: {'adjustment': adjustment});
    final data = resp.data['data'] as Map<String, dynamic>;
    final hijri = data['hijri'] as Map<String, dynamic>;
    final month = hijri['month'] as Map<String, dynamic>;
    final weekday = hijri['weekday'] as Map<String, dynamic>;
    return _HijriResult(
      day: hijri['day'] as String,
      monthNumber: (hijri['month'] as Map)['number'] as int,
      monthEn: month['en'] as String,
      monthAr: month['ar'] as String,
      year: hijri['year'] as String,
      weekdayEn: weekday['en'] as String,
      designation: hijri['designation']?['expanded'] as String? ?? 'AH',
      holidays: (hijri['holidays'] as List?)?.cast<String>() ?? [],
    );
  }

  String _gregorianLabel(DateTime d) => intl.DateFormat('EEE, d MMMM yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final region = _regions[_regionIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF0F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDark, region)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Region selector
                const SizedBox(height: 16),
                _buildRegionSelector(isDark),
                const SizedBox(height: 16),
                // Today's Hijri card
                _buildTodayCard(isDark, region),
                const SizedBox(height: 16),
                // Date converter
                _buildConverter(isDark),
                const SizedBox(height: 20),
                // Islamic months table
                _buildMonthsTable(isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark, _Region region) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFF1A2456), const Color(0xFF2E3B8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Islamic Calendar',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  Text('${region.emoji} ${region.label}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Text(_gregorianLabel(DateTime.now()),
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Region selector ─────────────────────────────────────────────────────────
  Widget _buildRegionSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calendar Region',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _regions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final selected = i == _regionIndex;
              final r = _regions[i];
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _regionIndex = i;
                    _todayHijri = null;
                    _selectedHijri = null;
                  });
                  await _loadToday();
                  if (_selectedHijri != null) await _convertSelectedDate();
                },
                child: AnimatedContainer(
                  duration: 250.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF2E3B8B), Color(0xFF1A2456)])
                        : null,
                    color: selected
                        ? null
                        : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: selected
                        ? [BoxShadow(
                            color: const Color(0xFF2E3B8B).withOpacity(0.35),
                            blurRadius: 10, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: Text('${r.emoji} ${r.label}',
                      style: TextStyle(
                          color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _regions[_regionIndex].description,
          style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
              fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ── Today's Hijri Card ──────────────────────────────────────────────────────
  Widget _buildTodayCard(bool isDark, _Region region) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3B8B), Color(0xFF1A2456)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2E3B8B).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : _todayHijri == null
              ? const Center(
                  child: Text('Could not load.',
                      style: TextStyle(color: Colors.white70)))
              : Column(
                  children: [
                    Text('Today',
                        style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      '${_todayHijri!.day} ${_todayHijri!.monthEn} ${_todayHijri!.year}',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _todayHijri!.designation,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _todayHijri!.monthAr,
                      style: GoogleFonts.scheherazadeNew(
                          color: const Color(0xFFC8A951),
                          fontSize: 28,
                          fontWeight: FontWeight.w600),
                      textDirection: ui.TextDirection.rtl,
                    ),
                    if (_todayHijri!.holidays.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xFFC8A951).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          _todayHijri!.holidays.join(', '),
                          style: const TextStyle(
                              color: Color(0xFFC8A951), fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text('${region.emoji} ${region.label}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  // ── Date Converter ─────────────────────────────────────────────────────────
  Widget _buildConverter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date Converter',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 14),
          // Date picker row
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                await _convertSelectedDate();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _gregorianLabel(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.primary.withOpacity(0.6)),
                ],
              ),
            ),
          ),
          // Result
          if (_converting)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_selectedHijri != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    '${_selectedHijri!.weekdayEn}, '
                    '${_selectedHijri!.day} ${_selectedHijri!.monthEn} '
                    '${_selectedHijri!.year} ${_selectedHijri!.designation}',
                    style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedHijri!.monthAr,
                    style: GoogleFonts.scheherazadeNew(
                        color: AppColors.primary,
                        fontSize: 22),
                    textDirection: ui.TextDirection.rtl,
                  ),
                  if (_selectedHijri!.holidays.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('🌟 ${_selectedHijri!.holidays.join(', ')}',
                        style: const TextStyle(
                            color: Color(0xFFC8A951), fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Islamic Months Table ───────────────────────────────────────────────────
  Widget _buildMonthsTable(bool isDark) {
    final months = [
      ('Muharram', 'محرم', 'Sacred month'),
      ('Safar', 'صفر', 'The month of travel'),
      ('Rabi al-Awwal', 'ربيع الأول', 'Birth of the Prophet ﷺ'),
      ('Rabi al-Thani', 'ربيع الثاني', 'Spring'),
      ("Jumada al-Awwal", 'جمادى الأولى', 'Dry month'),
      ("Jumada al-Thani", 'جمادى الثانية', 'Second dry month'),
      ('Rajab', 'رجب', 'Sacred — Isra Miraj'),
      ("Sha'ban", 'شعبان', 'Laylat al-Baraat'),
      ('Ramadan', 'رمضان', 'Month of fasting & Quran'),
      ('Shawwal', 'شوال', 'Eid al-Fitr'),
      ("Dhul Qadah", 'ذو القعدة', 'Sacred — no battles'),
      ("Dhul Hijjah", 'ذو الحجة', 'Eid al-Adha & Hajj'),
    ];

    final currentMonth = _todayHijri?.monthNumber ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Islamic Months (Hijri)',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 12),
        ...months.asMap().entries.map((entry) {
          final i = entry.key;
          final (en, ar, note) = entry.value;
          final isCurrentMonth = (i + 1) == currentMonth;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isCurrentMonth
                  ? const LinearGradient(
                      colors: [Color(0xFF2E3B8B), Color(0xFF1A2456)])
                  : null,
              color: isCurrentMonth
                  ? null
                  : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isCurrentMonth
                  ? [BoxShadow(
                      color: const Color(0xFF2E3B8B).withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF2E3B8B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('${i + 1}',
                      style: TextStyle(
                          color: isCurrentMonth
                              ? Colors.white
                              : const Color(0xFF2E3B8B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(en,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isCurrentMonth ? Colors.white : null,
                              fontSize: 14)),
                      Text(note,
                          style: TextStyle(
                              fontSize: 11,
                              color: isCurrentMonth ? Colors.white60 : Colors.grey[500])),
                    ],
                  ),
                ),
                Text(ar,
                    style: GoogleFonts.scheherazadeNew(
                        fontSize: 18,
                        color: isCurrentMonth
                            ? const Color(0xFFC8A951)
                            : const Color(0xFF2E3B8B),
                        fontWeight: FontWeight.w600),
                    textDirection: TextDirection.rtl),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 30 * i));
        }),
      ],
    );
  }
}

class _Region {
  final String label;
  final String emoji;
  final int adjustment;
  final String description;
  const _Region(this.label, this.emoji, this.adjustment, this.description);
}

class _HijriResult {
  final String day;
  final int monthNumber;
  final String monthEn;
  final String monthAr;
  final String year;
  final String weekdayEn;
  final String designation;
  final List<String> holidays;
  const _HijriResult({
    required this.day,
    required this.monthNumber,
    required this.monthEn,
    required this.monthAr,
    required this.year,
    required this.weekdayEn,
    required this.designation,
    required this.holidays,
  });
}
