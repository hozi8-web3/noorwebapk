import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/ayah_model.dart';
import '../quran/bloc/quran_bloc.dart';

class AyahReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  const AyahReaderScreen(
      {super.key, required this.surahNumber, required this.surahName});

  @override
  State<AyahReaderScreen> createState() => _AyahReaderScreenState();
}

class _AyahReaderScreenState extends State<AyahReaderScreen> {
  double _fontSize = 22;
  bool _showTranslation = true;

  // Audio Player State
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int? _playingIndex; // Tracks which ayah index is currently active
  List<AyahModel> _ayahs = []; // To hold loaded ayahs for auto-play
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _playNext();
    });

    context
        .read<QuranBloc>()
        .add(LoadAyahs(widget.surahNumber, widget.surahName));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAyah(int index) async {
    if (_playingIndex == index && _isPlaying) {
      await _audioPlayer.pause();
      return;
    }
    
    if (_ayahs.isEmpty) return;
    
    final ayah = _ayahs[index];
    final url = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${ayah.number}.mp3';
    
    setState(() => _playingIndex = index);

    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/ayah_${ayah.number}.mp3';
    final file = File(localPath);

    if (await file.exists()) {
      await _audioPlayer.play(DeviceFileSource(localPath));
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
  }

  Future<void> _downloadSurahAudio() async {
    if (_ayahs.isEmpty) return;
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dio = Dio();
      
      for (int i = 0; i < _ayahs.length; i++) {
        final ayah = _ayahs[i];
        final url = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${ayah.number}.mp3';
        final savePath = '${dir.path}/ayah_${ayah.number}.mp3';
        
        if (!await File(savePath).exists()) {
          await dio.download(url, savePath);
        }
        
        if (mounted) {
          setState(() {
            _downloadProgress = (i + 1) / _ayahs.length;
          });
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Surah audio downloaded for offline playback!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _playNext() {
    if (_ayahs.isEmpty || _playingIndex == null) return;
    final nextIndex = _playingIndex! + 1;
    if (nextIndex < _ayahs.length) {
      _playAyah(nextIndex);
    } else {
      setState(() {
        _playingIndex = null;
        _isPlaying = false;
      });
    }
  }

  void _resumeOrPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else if (_playingIndex != null) {
      await _audioPlayer.resume();
    } else if (_ayahs.isNotEmpty) {
      _playAyah(0); // Play from start if nothing is selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.surahName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Surah ${widget.surahNumber}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          if (_isDownloading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(value: _downloadProgress, strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download Audio',
              onPressed: _downloadSurahAudio,
            ),
          IconButton(
            icon: Icon(_showTranslation
                ? Icons.translate
                : Icons.translate_outlined),
            tooltip: 'Toggle translation',
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            onSelected: (v) => setState(() => _fontSize = v),
            itemBuilder: (_) => [16, 20, 24, 28, 32]
                .map((s) => PopupMenuItem(value: s.toDouble(), child: Text('$s pt')))
                .toList(),
          ),
        ],
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is QuranError) {
            return Center(child: Text(state.message));
          }
          if (state is AyahsLoaded) {
            _ayahs = state.ayahs;
            return Stack(
              children: [
                _buildAyahList(context, state),
                if (_playingIndex != null || _isPlaying)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: _buildAudioPlayerBar(),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAyahList(BuildContext context, AyahsLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // padding for audio bar
      itemCount: state.ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildBismillah();
        final ayahIndex = index - 1;
        final ayah = state.ayahs[ayahIndex];
        final isBookmarked = state.bookmarks.contains(ayah.bookmarkKey);
        return _AyahCard(
          ayah: ayah,
          isBookmarked: isBookmarked,
          isPlaying: _playingIndex == ayahIndex,
          fontSize: _fontSize,
          showTranslation: _showTranslation,
          onBookmark: () =>
              context.read<QuranBloc>().add(ToggleBookmark(ayah.bookmarkKey)),
          onPlay: () => _playAyah(ayahIndex),
        );
      },
    );
  }

  Widget _buildAudioPlayerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.accent,
                radius: 20,
                child: Icon(Icons.music_note, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Mishary Alafasy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    _playingIndex != null ? 'Playing Ayah ${_playingIndex! + 1}' : 'Ready',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                color: Colors.white,
                iconSize: 36,
                padding: EdgeInsets.zero,
                onPressed: _resumeOrPause,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white70,
                iconSize: 20,
                onPressed: () {
                  _audioPlayer.stop();
                  setState(() {
                    _playingIndex = null;
                    _isPlaying = false;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 26,
              color: Colors.white,
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final bool isBookmarked;
  final bool isPlaying;
  final double fontSize;
  final bool showTranslation;
  final VoidCallback onBookmark;
  final VoidCallback onPlay;
  
  const _AyahCard({
    required this.ayah,
    required this.isBookmarked,
    required this.isPlaying,
    required this.fontSize,
    required this.showTranslation,
    required this.onBookmark,
    required this.onPlay,
  });

  String _toArabicNumeral(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah number + bookmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlaying ? AppColors.accent : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: TextStyle(
                        color: isPlaying ? Colors.white : AppColors.primary, 
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle_outline, size: 22),
                      color: isPlaying ? AppColors.accent : AppColors.primary,
                      onPressed: onPlay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: ayah.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ayah copied')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: isBookmarked ? AppColors.accent : null,
                        size: 20,
                      ),
                      onPressed: onBookmark,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Arabic text
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${ayah.text} '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '\u06dd', // Arabic End of Ayah Symbol
                          style: GoogleFonts.scheherazadeNew(
                            color: const Color(0xFFC8A951),
                            fontSize: fontSize * 1.5, // Make the circle slightly larger
                          ),
                        ),
                        Text(
                          _toArabicNumeral(ayah.numberInSurah),
                          style: GoogleFonts.scheherazadeNew(
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                            fontSize: fontSize * 0.6, // Fit number inside
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.scheherazadeNew(
                fontSize: fontSize,
                height: 1.9,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            // Translation
            if (showTranslation && ayah.translation != null) ...[
              const Divider(height: 20),
              Text(
                ayah.translation!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.6,
                    ),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
