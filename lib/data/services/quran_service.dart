import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

class QuranService {
  final Dio _dio;

  QuranService() : _dio = Dio(BaseOptions(baseUrl: AppConstants.alQuranBaseUrl));

  Future<List<SurahModel>> fetchSurahList() async {
    final response = await _dio.get('/surah');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => SurahModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AyahModel>> fetchSurahAyahs(int surahNumber) async {
    // Fetch Arabic + Urdu translation concurrently
    final results = await Future.wait([
      _dio.get('/surah/$surahNumber/${AppConstants.quranArabicEdition}'),
      _dio.get('/surah/$surahNumber/${AppConstants.quranUrduEdition}'),
    ]);

    final arabicAyahs = (results[0].data['data']['ayahs'] as List<dynamic>)
        .map((e) => AyahModel.fromJson(e as Map<String, dynamic>, surahNumber: surahNumber))
        .toList();

    final urduAyahs = (results[1].data['data']['ayahs'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['text'] as String)
        .toList();

    // Merge translations
    return List.generate(arabicAyahs.length, (i) {
      return arabicAyahs[i].copyWith(
        translation: i < urduAyahs.length ? urduAyahs[i] : null,
      );
    });
  }

  Future<List<AyahModel>> searchQuran(String query) async {
    final response = await _dio.get(
      '/search/${Uri.encodeComponent(query)}/all/${AppConstants.quranUrduEdition}',
    );
    final matches = response.data['data']['matches'] as List<dynamic>;
    return matches.take(50).map((e) {
      final map = e as Map<String, dynamic>;
      return AyahModel(
        number: (map['number'] as num?)?.toInt() ?? 0,
        numberInSurah: (map['numberInSurah'] as num).toInt(),
        text: map['text'] as String,
        translation: null, // Basic search might only return text
        surahNumber: (map['surah']['number'] as num).toInt(),
        juz: (map['juz'] as num?)?.toInt() ?? 0,
        page: (map['page'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
