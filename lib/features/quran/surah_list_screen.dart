import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/surah_model.dart';
import '../quran/bloc/quran_bloc.dart';
import 'ayah_reader_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<SurahModel>? _cachedSurahs;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search Quran...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (q) {
                  setState(() => _searchQuery = q.trim());
                },
              )
            : const Text('Quran Majeed'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is QuranError && _cachedSurahs == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<QuranBloc>().add(LoadSurahList()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SurahListLoaded) _cachedSurahs = state.surahs;
          
          if (_cachedSurahs != null) {
            final filtered = _cachedSurahs!.where((s) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return s.number.toString() == q ||
                  s.englishName.toLowerCase().contains(q) ||
                  s.englishNameTranslation.toLowerCase().contains(q) ||
                  s.name.contains(q);
            }).toList();
            
            if (filtered.isEmpty) {
              return Center(
                child: Text('No surahs found for "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey)),
              );
            }
            return _buildSurahList(context, filtered, isDark);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSurahList(
      BuildContext context, List<SurahModel> surahs, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final surah = surahs[i];
        return _SurahTile(surah: surah, index: i)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 20 * i > 400 ? 400 : 20 * i));
      },
    );
  }

  Widget _buildSearchResults(
      BuildContext context, SearchResultsLoaded state, bool isDark) {
    if (state.results.isEmpty) {
      return Center(
        child: Text(
          'No results for "${state.query}"',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final ayah = state.results[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ayah.text,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 20,
                    height: 1.8,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                if (ayah.translation != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    ayah.translation!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Ayah ${ayah.numberInSurah} | Surah ${ayah.surahNumber}',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahModel surah;
  final int index;
  const _SurahTile({required this.surah, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AyahReaderScreen(
            surahNumber: surah.number,
            surahName: surah.englishName,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.number}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs • ${surah.revelationType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              surah.name,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
