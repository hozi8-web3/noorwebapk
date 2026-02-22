import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/tasbeeh_preset_model.dart';

/// Wraps SharedPreferences with typed getters/setters AND a generic JSON
/// cache with optional date-based TTL.
class StorageService {
  final SharedPreferences _prefs;
  StorageService(this._prefs);

  // ──────────────────────────────────────────────────────────
  // ONBOARDING
  // ──────────────────────────────────────────────────────────
  bool get isFirstLaunch => _prefs.getBool('is_first_launch') ?? true;
  Future<void> completeFirstLaunch() async => _prefs.setBool('is_first_launch', false);

  // ──────────────────────────────────────────────────────────
  // GENERIC JSON CACHE
  // ──────────────────────────────────────────────────────────

  /// Store any JSON-encodable value under [key].
  Future<void> cacheJson(String key, dynamic value) async {
    final encoded = json.encode(value);
    await _prefs.setString(key, encoded);
    // Stamp the date so we can invalidate daily caches
    final today = _dateKey(DateTime.now());
    await _prefs.setString('${key}_date', today);
  }

  /// Retrieve a cached value. Returns null if missing.
  dynamic getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return json.decode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Returns cached value only if it was stored **today** (for prayer times).
  dynamic getJsonToday(String key) {
    final today = _dateKey(DateTime.now());
    final storedDate = _prefs.getString('${key}_date');
    if (storedDate != today) return null;
    return getJson(key);
  }

  /// Returns true if the key has a cached value.
  bool hasCacheFor(String key) => _prefs.containsKey(key);

  /// Returns true if the key was cached today.
  bool hasCacheForToday(String key) {
    final today = _dateKey(DateTime.now());
    return _prefs.getString('${key}_date') == today;
  }

  /// Removes a cached entry.
  Future<void> clearCache(String key) async {
    await _prefs.remove(key);
    await _prefs.remove('${key}_date');
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ──────────────────────────────────────────────────────────
  // CITY / LOCATION
  // ──────────────────────────────────────────────────────────
  String get cityName =>
      _prefs.getString(AppConstants.keyCityName) ?? AppConstants.defaultCity;
  String get countryCode =>
      _prefs.getString(AppConstants.keyCountryCode) ?? AppConstants.defaultCountry;

  Future<void> saveCity(String city, String country) async {
    await _prefs.setString(AppConstants.keyCityName, city);
    await _prefs.setString(AppConstants.keyCountryCode, country);
  }

  // ──────────────────────────────────────────────────────────
  // THEME
  // ──────────────────────────────────────────────────────────
  bool get isDarkMode =>
      _prefs.getBool(AppConstants.keyThemeMode) ?? false;
  Future<void> saveThemeMode(bool isDark) async =>
      _prefs.setBool(AppConstants.keyThemeMode, isDark);

  // ──────────────────────────────────────────────────────────
  // BOOKMARKS
  // ──────────────────────────────────────────────────────────
  List<String> get bookmarks =>
      _prefs.getStringList(AppConstants.keyBookmarks) ?? [];
  Future<void> saveBookmarks(List<String> list) async =>
      _prefs.setStringList(AppConstants.keyBookmarks, list);
  Future<void> addBookmark(String key) async {
    final list = bookmarks;
    if (!list.contains(key)) {
      list.add(key);
      await saveBookmarks(list);
    }
  }
  Future<void> removeBookmark(String key) async {
    final list = bookmarks;
    list.remove(key);
    await saveBookmarks(list);
  }

  // ──────────────────────────────────────────────────────────
  // TASBEEH
  // ──────────────────────────────────────────────────────────
  int get tasbeehCount =>
      _prefs.getInt(AppConstants.keyTasbeehCount) ?? 0;
  int get tasbeehTotal =>
      _prefs.getInt(AppConstants.keyTasbeehTotal) ?? 0;
  String get tasbeehPreset =>
      _prefs.getString(AppConstants.keyTasbeehPreset) ?? 'SubhanAllah';
  Future<void> saveTasbeeh(int count, int total, String preset) async {
    await _prefs.setInt(AppConstants.keyTasbeehCount, count);
    await _prefs.setInt(AppConstants.keyTasbeehTotal, total);
    await _prefs.setString(AppConstants.keyTasbeehPreset, preset);
  }

  List<TasbeehPresetModel> get customTasbeehPresets {
    final raw = _prefs.getString('custom_tasbeeh_presets');
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => TasbeehPresetModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addCustomTasbeehPreset(TasbeehPresetModel preset) async {
    final list = customTasbeehPresets;
    list.add(preset);
    await _prefs.setString('custom_tasbeeh_presets', json.encode(list.map((e) => e.toJson()).toList()));
  }

  // ──────────────────────────────────────────────────────────
  // LAST SURAH
  // ──────────────────────────────────────────────────────────
  int get lastSurah =>
      _prefs.getInt(AppConstants.keyLastSurah) ?? 1;
  Future<void> saveLastSurah(int surahNumber) async =>
      _prefs.setInt(AppConstants.keyLastSurah, surahNumber);

  // ──────────────────────────────────────────────────────────
  // GPS COORDINATES (last known)
  // ──────────────────────────────────────────────────────────
  double? get lastLatitude => _prefs.getDouble(AppConstants.keyLastLat);
  double? get lastLongitude => _prefs.getDouble(AppConstants.keyLastLon);
  Future<void> saveCoordinates(double lat, double lon) async {
    await _prefs.setDouble(AppConstants.keyLastLat, lat);
    await _prefs.setDouble(AppConstants.keyLastLon, lon);
  }
}
