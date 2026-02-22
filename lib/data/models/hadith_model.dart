import 'package:equatable/equatable.dart';

class HadithModel extends Equatable {
  final int hadithnumber;
  final String text;
  final String reference;
  final String? arabic;

  const HadithModel({
    required this.hadithnumber,
    required this.text,
    required this.reference,
    this.arabic,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    // Reference can be an object {book, hadith} or a string — handle both
    String ref = '';
    final rawRef = json['reference'];
    if (rawRef is Map) {
      ref = 'Book ${rawRef['book']}, Hadith ${rawRef['hadith']}';
    } else if (rawRef is String) {
      ref = rawRef;
    }

    return HadithModel(
      hadithnumber: (json['hadithnumber'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      reference: ref,
      arabic: json['arabic'] as String?,
    );
  }

  @override
  List<Object?> get props => [hadithnumber, text, reference];
}
