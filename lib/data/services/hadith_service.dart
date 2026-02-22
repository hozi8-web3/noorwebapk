import 'package:dio/dio.dart';
import '../models/hadith_model.dart';

/// Fetches hadiths section-by-section from the fawazahmed0 CDN API.
/// Endpoint: https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/{edition}/{section}.json
class HadithService {
  static const String _baseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  /// Fetches sections for both Arabic and Urdu simultaneously, merging them.
  Future<List<HadithModel>> fetchHadiths(String bookKey) async {
    final List<HadithModel> results = [];

    // Loop up to 20 sections to get enough hadiths
    for (int section = 1; section <= 20; section++) {
      try {
        final uraUrl = '$_baseUrl/urd-$bookKey/$section.json';
        final araUrl = '$_baseUrl/ara-$bookKey/$section.json';

        // Dual fetch
        final responses = await Future.wait([
          _dio.get(uraUrl).catchError((_) => Response(requestOptions: RequestOptions(path: ''))),
          _dio.get(araUrl).catchError((_) => Response(requestOptions: RequestOptions(path: ''))),
        ]);

        final urdData = responses[0].data;
        final araData = responses[1].data;

        if (urdData != null && urdData is Map && araData != null && araData is Map) {
          final urdList = urdData['hadiths'] as List<dynamic>? ?? [];
          final araList = araData['hadiths'] as List<dynamic>? ?? [];

          final minLen = urdList.length < araList.length ? urdList.length : araList.length;

          for (int i = 0; i < minLen; i++) {
            final uItem = urdList[i] as Map<String, dynamic>;
            final aItem = araList[i] as Map<String, dynamic>;

            String ref = '';
            final rawRef = uItem['reference'];
            if (rawRef is Map) {
              ref = 'Book ${rawRef['book']}, Hadith ${rawRef['hadith']}';
            } else if (rawRef is String) {
              ref = rawRef;
            }

            results.add(HadithModel(
              hadithnumber: (uItem['hadithnumber'] as num?)?.toInt() ?? 0,
              text: (uItem['text'] as String?)?.trim() ?? '',
              arabic: (aItem['text'] as String?)?.trim() ?? '',
              reference: ref,
            ));
          }
        }
      } catch (_) {
        // Stop if a section fails entirely
        if (results.isNotEmpty) break;
      }

      if (results.length >= 50) break;
    }

    if (results.isEmpty) {
      throw Exception('Could not load hadiths. Check your internet connection.');
    }

    return results.take(100).toList();
  }
}
