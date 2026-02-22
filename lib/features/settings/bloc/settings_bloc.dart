import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/storage/storage_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final StorageService _storage;

  SettingsBloc(this._storage) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoad);
    on<ToggleTheme>(_onToggleTheme);
  }

  void _onLoad(LoadSettings event, Emitter<SettingsState> emit) {
    emit(SettingsLoaded(_storage.isDarkMode));
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<SettingsState> emit) async {
    final current = state is SettingsLoaded
        ? (state as SettingsLoaded).isDarkMode
        : false;
    await _storage.saveThemeMode(!current);
    emit(SettingsLoaded(!current));
  }
}
