class TasbeehPresetModel {
  final String name;
  final String arabic;
  final int target;
  final String transliteration;

  const TasbeehPresetModel({
    required this.name,
    required this.arabic,
    required this.target,
    required this.transliteration,
  });

  factory TasbeehPresetModel.fromJson(Map<String, dynamic> json) {
    return TasbeehPresetModel(
      name: json['name'] as String,
      arabic: json['arabic'] as String,
      target: json['target'] as int,
      transliteration: json['transliteration'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'arabic': arabic,
        'target': target,
        'transliteration': transliteration,
      };

  static const List<TasbeehPresetModel> defaultPresets = [
    TasbeehPresetModel(
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللَّهِ',
      target: 33,
      transliteration: 'SubhanAllah',
    ),
    TasbeehPresetModel(
      name: 'Alhamdulillah',
      arabic: 'الحَمْدُ لِلَّهِ',
      target: 33,
      transliteration: 'Alhamdulillah',
    ),
    TasbeehPresetModel(
      name: 'AllahuAkbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      target: 34,
      transliteration: 'Allahu Akbar',
    ),
    TasbeehPresetModel(
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      target: 100,
      transliteration: 'Astaghfirullah',
    ),
    TasbeehPresetModel(
      name: 'Custom',
      arabic: 'ذِكر',
      target: 99,
      transliteration: 'Custom Dhikr',
    ),
  ];
}
