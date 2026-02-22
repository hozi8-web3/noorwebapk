import 'package:equatable/equatable.dart';

class PrayerTimeModel extends Equatable {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String city;

  const PrayerTimeModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.city,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json, {String city = ''}) {
    final timings = json['timings'] as Map<String, dynamic>;
    final dateData = json['date'] as Map<String, dynamic>;
    return PrayerTimeModel(
      fajr: _cleanTime(timings['Fajr'] as String),
      sunrise: _cleanTime(timings['Sunrise'] as String),
      dhuhr: _cleanTime(timings['Dhuhr'] as String),
      asr: _cleanTime(timings['Asr'] as String),
      maghrib: _cleanTime(timings['Maghrib'] as String),
      isha: _cleanTime(timings['Isha'] as String),
      date: dateData['readable'] as String? ?? '',
      city: city,
    );
  }

  static String _cleanTime(String time) => time.split(' ').first;

  /// Deserialize from our own cache JSON (flat format)
  factory PrayerTimeModel.fromCacheJson(Map<String, dynamic> json) =>
      PrayerTimeModel(
        fajr: json['fajr'] as String,
        sunrise: json['sunrise'] as String,
        dhuhr: json['dhuhr'] as String,
        asr: json['asr'] as String,
        maghrib: json['maghrib'] as String,
        isha: json['isha'] as String,
        date: json['date'] as String,
        city: json['city'] as String,
      );

  Map<String, dynamic> toJson() => {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'date': date,
        'city': city,
      };

  List<Map<String, String>> get prayers => [
        {'name': 'Fajr', 'time': fajr},
        {'name': 'Sunrise', 'time': sunrise},
        {'name': 'Dhuhr', 'time': dhuhr},
        {'name': 'Asr', 'time': asr},
        {'name': 'Maghrib', 'time': maghrib},
        {'name': 'Isha', 'time': isha},
      ];

  @override
  List<Object?> get props => [fajr, dhuhr, asr, maghrib, isha, date, city];
}
