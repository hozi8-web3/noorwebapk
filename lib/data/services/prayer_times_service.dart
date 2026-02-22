import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/prayer_time_model.dart';

class PrayerTimesService {
  final Dio _dio;

  PrayerTimesService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.alAdhanBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  /// Fetch prayer times by city name (fallback)
  Future<PrayerTimeModel> fetchPrayerTimes(String city, String country) async {
    final response = await _dio.get(
      '/timingsByCity',
      queryParameters: {
        'city': city,
        'country': country,
        'method': AppConstants.defaultCalculationMethod,
      },
    );
    return PrayerTimeModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
      city: city,
    );
  }

  /// Fetch prayer times by GPS coordinates (preferred)
  Future<PrayerTimeModel> fetchPrayerTimesByLocation(
      double latitude, double longitude, String cityLabel) async {
    final response = await _dio.get(
      '/timings',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'method': AppConstants.defaultCalculationMethod,
      },
    );
    return PrayerTimeModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
      city: cityLabel,
    );
  }

  Future<List<PrayerTimeModel>> fetchMonthlyPrayerTimes(
      String city, String country, int month, int year) async {
    final response = await _dio.get(
      '/calendarByCity',
      queryParameters: {
        'city': city,
        'country': country,
        'method': AppConstants.defaultCalculationMethod,
        'month': month,
        'year': year,
      },
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) =>
            PrayerTimeModel.fromJson(e as Map<String, dynamic>, city: city))
        .toList();
  }
}
