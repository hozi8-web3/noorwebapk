import 'dart:convert';
import '../models/prayer_time_model.dart';
import '../services/prayer_times_service.dart';
import '../storage/storage_service.dart';
import '../../core/constants/app_constants.dart';

class PrayerTimesRepository {
  final PrayerTimesService _service;
  final StorageService _storage;

  PrayerTimesRepository(this._service, this._storage);

  String get cityName => _storage.cityName;
  String get countryCode => _storage.countryCode;

  // ── Cache key helpers ─────────────────────────────────────
  String _cityKey() {
    final now = DateTime.now();
    return '${AppConstants.cachePrayerTimesPrefix}'
        '${now.year}_${now.month}_${now.day}_${_storage.cityName}';
  }

  String _gpsKey(double lat, double lon) {
    final now = DateTime.now();
    final latS = lat.toStringAsFixed(2);
    final lonS = lon.toStringAsFixed(2);
    return '${AppConstants.cachePrayerTimesPrefix}'
        '${now.year}_${now.month}_${now.day}_${latS}_$lonS';
  }

  // ── By city (with daily cache) ────────────────────────────
  Future<PrayerTimeModel> getPrayerTimes() async {
    final key = _cityKey();

    if (_storage.hasCacheForToday(key)) {
      final data = _storage.getJson(key);
      if (data != null) {
        return PrayerTimeModel.fromCacheJson(
            data as Map<String, dynamic>);
      }
    }

    final model = await _service.fetchPrayerTimes(
        _storage.cityName, _storage.countryCode);
    await _storage.cacheJson(key, model.toJson());
    return model;
  }

  // ── By GPS (with daily cache) ─────────────────────────────
  Future<PrayerTimeModel> getPrayerTimesByLocation(
      double lat, double lon, String cityLabel) async {
    await _storage.saveCoordinates(lat, lon);
    await _storage.saveCity(cityLabel, 'GPS');

    final key = _gpsKey(lat, lon);
    if (_storage.hasCacheForToday(key)) {
      final data = _storage.getJson(key);
      if (data != null) {
        return PrayerTimeModel.fromCacheJson(
            data as Map<String, dynamic>);
      }
    }

    final model =
        await _service.fetchPrayerTimesByLocation(lat, lon, cityLabel);
    await _storage.cacheJson(key, model.toJson());
    return model;
  }

  // ── Try cached GPS first, else fetch ─────────────────────
  /// Used by Ramadan screen to get today's Fajr/Maghrib without triggering
  /// a full GPS request. Uses last-known coordinates if available.
  Future<PrayerTimeModel?> getCachedOrFetchPrayerTimes() async {
    // Try today's city cache
    final cityKey = _cityKey();
    if (_storage.hasCacheForToday(cityKey)) {
      final data = _storage.getJson(cityKey);
      if (data != null) {
        return PrayerTimeModel.fromJson(
            data as Map<String, dynamic>,
            city: _storage.cityName);
      }
    }

    // Try today's GPS cache with last known coordinates
    final lat = _storage.lastLatitude;
    final lon = _storage.lastLongitude;
    if (lat != null && lon != null) {
      final gpsKey = _gpsKey(lat, lon);
      if (_storage.hasCacheForToday(gpsKey)) {
        final data = _storage.getJson(gpsKey);
        if (data != null) {
          return PrayerTimeModel.fromJson(
              data as Map<String, dynamic>,
              city: _storage.cityName);
        }
      }
    }

    // Attempt a fresh fetch by city
    try {
      return await getPrayerTimes();
    } catch (_) {
      return null;
    }
  }

  Future<PrayerTimeModel> getPrayerTimesForCity(
      String city, String country) async {
    await _storage.saveCity(city, country);
    final model = await _service.fetchPrayerTimes(city, country);
    final key = _cityKey();
    await _storage.cacheJson(key, model.toJson());
    return model;
  }

  Future<List<PrayerTimeModel>> getMonthlyPrayerTimes(
          int month, int year) =>
      _service.fetchMonthlyPrayerTimes(
          _storage.cityName, _storage.countryCode, month, year);
}
