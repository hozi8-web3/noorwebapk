class AppConstants {
  // API Base URLs
  static const String alAdhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String alQuranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String hadithBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  // Default Settings
  static const String defaultCity = 'Karachi';
  static const String defaultCountry = 'PK';
  static const int defaultCalculationMethod = 1; // University of Islamic Sciences, Karachi

  // Storage Keys
  static const String keyCityName = 'city_name';
  static const String keyCountryCode = 'country_code';
  static const String keyThemeMode = 'theme_mode';
  static const String keyBookmarks = 'quran_bookmarks';
  static const String keyTasbeehCount = 'tasbeeh_count';
  static const String keyTasbeehTotal = 'tasbeeh_total';
  static const String keyTasbeehPreset = 'tasbeeh_preset';
  static const String keyLastSurah = 'last_surah';
  // GPS
  static const String keyLastLat = 'last_lat';
  static const String keyLastLon = 'last_lon';
  // Cache keys
  static const String cacheQuranSurahList = 'cache_quran_surah_list';
  static const String cacheQuranAyahsPrefix = 'cache_quran_ayahs_'; // + surahNumber
  static const String cacheHadithPrefix = 'cache_hadith_'; // + edition
  static const String cachePrayerTimesPrefix = 'cache_prayer_'; // + date_lat_lon

  // App
  static const String appName = 'NoorWeb';

  // Quran editions
  static const String quranArabicEdition = 'quran-uthmani';
  static const String quranUrduEdition = 'ur.junagarhi';
  static const String quranEnglishEdition = 'en.sahih';

  // Hadith Books
  static const List<Map<String, String>> hadithBooks = [
    {'key': 'bukhari', 'name': 'Sahih Bukhari', 'edition': 'eng-bukhari'},
    {'key': 'muslim', 'name': 'Sahih Muslim', 'edition': 'eng-muslim'},
    {'key': 'abudawud', 'name': 'Abu Dawud', 'edition': 'eng-abudawud'},
    {'key': 'tirmidhi', 'name': 'Tirmidhi', 'edition': 'eng-tirmidhi'},
    {'key': 'ibnmajah', 'name': 'Ibn Majah', 'edition': 'eng-ibnmajah'},
  ];

  // Prophet list
  static const List<Map<String, String>> prophets = [
    {'name': 'Adam', 'arabic': 'آدم', 'suffix': 'AS'},
    {'name': 'Idris', 'arabic': 'إدريس', 'suffix': 'AS'},
    {'name': 'Nuh', 'arabic': 'نوح', 'suffix': 'AS'},
    {'name': 'Hud', 'arabic': 'هود', 'suffix': 'AS'},
    {'name': 'Salih', 'arabic': 'صالح', 'suffix': 'AS'},
    {'name': 'Ibrahim', 'arabic': 'إبراهيم', 'suffix': 'AS'},
    {'name': 'Lut', 'arabic': 'لوط', 'suffix': 'AS'},
    {'name': 'Ismail', 'arabic': 'إسماعيل', 'suffix': 'AS'},
    {'name': 'Ishaq', 'arabic': 'إسحاق', 'suffix': 'AS'},
    {'name': 'Yaqub', 'arabic': 'يعقوب', 'suffix': 'AS'},
    {'name': 'Yusuf', 'arabic': 'يوسف', 'suffix': 'AS'},
    {'name': 'Ayyub', 'arabic': 'أيوب', 'suffix': 'AS'},
    {'name': "Shu'ayb", 'arabic': 'شعيب', 'suffix': 'AS'},
    {'name': 'Musa', 'arabic': 'موسى', 'suffix': 'AS'},
    {'name': 'Harun', 'arabic': 'هارون', 'suffix': 'AS'},
    {'name': 'Dhul-Kifl', 'arabic': 'ذو الكفل', 'suffix': 'AS'},
    {'name': 'Dawud', 'arabic': 'داود', 'suffix': 'AS'},
    {'name': 'Sulayman', 'arabic': 'سليمان', 'suffix': 'AS'},
    {'name': 'Ilyas', 'arabic': 'إلياس', 'suffix': 'AS'},
    {'name': "Al-Yasa'", 'arabic': 'اليسع', 'suffix': 'AS'},
    {'name': 'Yunus', 'arabic': 'يونس', 'suffix': 'AS'},
    {'name': 'Zakariya', 'arabic': 'زكريا', 'suffix': 'AS'},
    {'name': 'Yahya', 'arabic': 'يحيى', 'suffix': 'AS'},
    {'name': 'Isa', 'arabic': 'عيسى', 'suffix': 'AS'},
    {'name': 'Muhammad', 'arabic': 'محمد', 'suffix': 'SAW'},
  ];
}
