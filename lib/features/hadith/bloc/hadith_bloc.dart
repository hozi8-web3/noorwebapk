import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/hadith_model.dart';
import '../../../data/repositories/hadith_repository.dart';

part 'hadith_event.dart';
part 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final HadithRepository _repo;

  HadithBloc(this._repo) : super(HadithInitial()) {
    on<LoadHadiths>(_onLoadHadiths);
  }

  Future<void> _onLoadHadiths(
      LoadHadiths event, Emitter<HadithState> emit) async {
    emit(HadithLoading());
    try {
      final hadiths = await _repo.getHadiths(event.edition);
      emit(HadithLoaded(hadiths, event.bookName));
    } catch (e) {
      emit(HadithError('Failed to load hadiths: $e'));
    }
  }
}
