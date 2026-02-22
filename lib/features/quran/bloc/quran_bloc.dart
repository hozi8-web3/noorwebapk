import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/models/ayah_model.dart';
import '../../../data/repositories/quran_repository.dart';

part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository _repo;

  QuranBloc(this._repo) : super(QuranInitial()) {
    on<LoadSurahList>(_onLoadSurahList);
    on<LoadAyahs>(_onLoadAyahs);
    on<SearchQuran>(_onSearchQuran);
    on<ToggleBookmark>(_onToggleBookmark);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadSurahList(
      LoadSurahList event, Emitter<QuranState> emit) async {
    emit(QuranLoading());
    try {
      final surahs = await _repo.getSurahList();
      emit(SurahListLoaded(surahs, _repo.getBookmarks()));
    } catch (e) {
      emit(QuranError('Failed to load Quran: $e'));
    }
  }

  Future<void> _onLoadAyahs(
      LoadAyahs event, Emitter<QuranState> emit) async {
    emit(QuranLoading());
    try {
      final ayahs = await _repo.getAyahs(event.surahNumber);
      emit(AyahsLoaded(
          ayahs, event.surahNumber, event.surahName, _repo.getBookmarks()));
    } catch (e) {
      emit(QuranError('Failed to load ayahs: $e'));
    }
  }

  Future<void> _onSearchQuran(
      SearchQuran event, Emitter<QuranState> emit) async {
    if (event.query.trim().isEmpty) {
      add(LoadSurahList());
      return;
    }
    emit(QuranLoading());
    try {
      final results = await _repo.searchQuran(event.query);
      emit(SearchResultsLoaded(results, event.query));
    } catch (e) {
      emit(QuranError('Search failed: $e'));
    }
  }

  Future<void> _onToggleBookmark(
      ToggleBookmark event, Emitter<QuranState> emit) async {
    final current = state;
    if (_repo.isBookmarked(event.bookmarkKey)) {
      await _repo.removeBookmark(event.bookmarkKey);
    } else {
      await _repo.addBookmark(event.bookmarkKey);
    }
    // Refresh current state with new bookmarks
    if (current is AyahsLoaded) {
      emit(AyahsLoaded(
          current.ayahs, current.surahNumber, current.surahName,
          _repo.getBookmarks()));
    } else if (current is SurahListLoaded) {
      emit(SurahListLoaded(current.surahs, _repo.getBookmarks()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<QuranState> emit) {
    add(LoadSurahList());
  }
}
