import 'dart:convert';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../services/quran_service.dart';
import '../storage/storage_service.dart';
import '../../core/constants/app_constants.dart';

class QuranRepository {
  final QuranService _service;
  final StorageService _storage;

  // In-memory cache (fast second access within same session)
  List<SurahModel>? _memoryCachedSurahs;
  final Map<int, List<AyahModel>> _memoryCachedAyahs = {};

  QuranRepository(this._service, this._storage);

  // ── Surah List ────────────────────────────────────────────
  Future<List<SurahModel>> getSurahList() async {
    // 1. In-memory hit
    if (_memoryCachedSurahs != null) return _memoryCachedSurahs!;

    // 2. SharedPreferences hit
    final cached = _storage.getJson(AppConstants.cacheQuranSurahList);
    if (cached != null) {
      _memoryCachedSurahs = (cached as List<dynamic>)
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return _memoryCachedSurahs!;
    }

    // 3. API fetch + persist
    _memoryCachedSurahs = await _service.fetchSurahList();
    await _storage.cacheJson(
      AppConstants.cacheQuranSurahList,
      _memoryCachedSurahs!.map((s) => s.toJson()).toList(),
    );
    return _memoryCachedSurahs!;
  }

  // ── Ayahs for a Surah ─────────────────────────────────────
  Future<List<AyahModel>> getAyahs(int surahNumber) async {
    // 1. In-memory hit
    if (_memoryCachedAyahs.containsKey(surahNumber)) {
      return _memoryCachedAyahs[surahNumber]!;
    }

    // 2. SharedPreferences hit
    final key = '${AppConstants.cacheQuranAyahsPrefix}$surahNumber';
    final cached = _storage.getJson(key);
    if (cached != null) {
      final ayahs = (cached as List<dynamic>)
          .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _memoryCachedAyahs[surahNumber] = ayahs;
      return ayahs;
    }

    // 3. API fetch + persist
    final ayahs = await _service.fetchSurahAyahs(surahNumber);
    _memoryCachedAyahs[surahNumber] = ayahs;
    await _storage.cacheJson(
        key, ayahs.map((a) => a.toJson()).toList());
    return ayahs;
  }

  Future<List<AyahModel>> searchQuran(String query) =>
      _service.searchQuran(query);

  // ── Bookmarks ─────────────────────────────────────────────
  List<String> getBookmarks() => _storage.bookmarks;
  Future<void> addBookmark(String key) => _storage.addBookmark(key);
  Future<void> removeBookmark(String key) => _storage.removeBookmark(key);
  bool isBookmarked(String key) => _storage.bookmarks.contains(key);
}
