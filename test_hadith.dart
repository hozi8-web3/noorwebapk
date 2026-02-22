import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get('https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-bukhari/1.json');
    final data = response.data;
    final List<dynamic> rawList = data['hadiths'];
    for (var e in rawList.take(2)) {
      String ref = '';
      final rawRef = e['reference'];
      if (rawRef is Map) {
        ref = 'Book ${rawRef['book']}, Hadith ${rawRef['hadith']}';
      } else if (rawRef is String) {
        ref = rawRef;
      }
      print('Parsed Ref: $ref');
      print('Parsed Num: ${e['hadithnumber']}');
    }
    print("Success!");
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}
