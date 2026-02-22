part of 'quran_bloc.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}
class QuranLoading extends QuranState {}
class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}

class SurahListLoaded extends QuranState {
  final List<SurahModel> surahs;
  final List<String> bookmarks;
  SurahListLoaded(this.surahs, this.bookmarks);
}

class AyahsLoaded extends QuranState {
  final List<AyahModel> ayahs;
  final int surahNumber;
  final String surahName;
  final List<String> bookmarks;
  AyahsLoaded(this.ayahs, this.surahNumber, this.surahName, this.bookmarks);
}

class SearchResultsLoaded extends QuranState {
  final List<AyahModel> results;
  final String query;
  SearchResultsLoaded(this.results, this.query);
}
