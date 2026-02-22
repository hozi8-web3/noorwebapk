import 'dart:convert';
import '../models/hadith_model.dart';
import '../services/hadith_service.dart';
import '../storage/storage_service.dart';
import '../../core/constants/app_constants.dart';

class HadithRepository {
  final HadithService _service;
  final StorageService _storage;

  // In-memory cache for current session
  final Map<String, List<HadithModel>> _memoryCache = {};

  HadithRepository(this._service, this._storage);

  Future<List<HadithModel>> getHadiths(String edition) async {
    // 1. In-memory hit
    if (_memoryCache.containsKey(edition)) return _memoryCache[edition]!;

    // 2. SharedPreferences hit (permanent — hadiths don't change)
    final key = '${AppConstants.cacheHadithPrefix}$edition';
    final cached = _storage.getJson(key);
    if (cached != null) {
      final hadiths = (cached as List<dynamic>)
          .map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _memoryCache[edition] = hadiths;
      return hadiths;
    }

    // 3. API fetch + persist
    final hadiths = await _service.fetchHadiths(edition);
    _memoryCache[edition] = hadiths;
    await _storage.cacheJson(
      key,
      hadiths
          .map((h) => {
                'hadithnumber': h.hadithnumber,
                'text': h.text,
                'reference': h.reference,
                'arabic': h.arabic,
              })
          .toList(),
    );
    return hadiths;
  }
}
