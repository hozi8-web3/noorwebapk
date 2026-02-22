import 'package:equatable/equatable.dart';

class AyahModel extends Equatable {
  final int number;
  final int numberInSurah;
  final String text;
  final String? translation;
  final int surahNumber;
  final int juz;
  final int page;

  const AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    required this.surahNumber,
    required this.juz,
    required this.page,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json, {int surahNumber = 0}) =>
      AyahModel(
        number: (json['number'] as num).toInt(),
        numberInSurah: (json['numberInSurah'] as num).toInt(),
        text: json['text'] as String,
        translation: json['translation'] as String?,
        surahNumber: (json['surahNumber'] as num?)?.toInt() ?? surahNumber,
        juz: (json['juz'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 0,
      );

  AyahModel copyWith({String? translation}) => AyahModel(
        number: number,
        numberInSurah: numberInSurah,
        text: text,
        translation: translation ?? this.translation,
        surahNumber: surahNumber,
        juz: juz,
        page: page,
      );

  String get bookmarkKey => '$surahNumber:$numberInSurah';

  Map<String, dynamic> toJson() => {
        'number': number,
        'numberInSurah': numberInSurah,
        'text': text,
        'translation': translation,
        'surahNumber': surahNumber,
        'juz': juz,
        'page': page,
      };

  @override
  List<Object?> get props => [number, numberInSurah, text, surahNumber];
}
