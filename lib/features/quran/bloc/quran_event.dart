part of 'quran_bloc.dart';

abstract class QuranEvent {}

class LoadSurahList extends QuranEvent {}

class LoadAyahs extends QuranEvent {
  final int surahNumber;
  final String surahName;
  LoadAyahs(this.surahNumber, this.surahName);
}

class SearchQuran extends QuranEvent {
  final String query;
  SearchQuran(this.query);
}

class ToggleBookmark extends QuranEvent {
  final String bookmarkKey;
  ToggleBookmark(this.bookmarkKey);
}

class ClearSearch extends QuranEvent {}
