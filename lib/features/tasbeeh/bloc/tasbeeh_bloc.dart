import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/tasbeeh_preset_model.dart';
import '../../../data/storage/storage_service.dart';

part 'tasbeeh_event.dart';
part 'tasbeeh_state.dart';

class TasbeehBloc extends Bloc<TasbeehEvent, TasbeehState> {
  final StorageService _storage;

  TasbeehBloc(this._storage) : super(TasbeehInitial()) {
    on<LoadTasbeeh>(_onLoad);
    on<IncrementTasbeeh>(_onIncrement);
    on<ResetTasbeeh>(_onReset);
    on<AddCustomPreset>(_onAddCustomPreset);
  }

  List<TasbeehPresetModel> get _allPresets => [
        ...TasbeehPresetModel.defaultPresets,
        ..._storage.customTasbeehPresets,
      ];

  void _onLoad(LoadTasbeeh event, Emitter<TasbeehState> emit) {
    final presetName = _storage.tasbeehPreset;
    final all = _allPresets;
    final preset = all.firstWhere((p) => p.name == presetName, orElse: () => all.first);
    emit(TasbeehLoaded(
      count: _storage.tasbeehCount,
      total: _storage.tasbeehTotal,
      preset: preset,
      allPresets: all,
    ));
  }

  Future<void> _onIncrement(
      IncrementTasbeeh event, Emitter<TasbeehState> emit) async {
    final current = state as TasbeehLoaded;
    final newCount = current.count + 1;
    final total = current.total + 1;
    final cycleComplete = newCount >= current.preset.target;
    final finalCount = cycleComplete ? 0 : newCount;

    await _storage.saveTasbeeh(finalCount, total, current.preset.name);
    emit(TasbeehLoaded(
      count: finalCount,
      total: total,
      preset: current.preset,
      allPresets: current.allPresets,
      cycleComplete: cycleComplete,
    ));
  }

  Future<void> _onReset(
      ResetTasbeeh event, Emitter<TasbeehState> emit) async {
    final current = state as TasbeehLoaded;
    await _storage.saveTasbeeh(0, 0, current.preset.name);
    emit(TasbeehLoaded(
        count: 0, total: 0, preset: current.preset, allPresets: current.allPresets));
  }

  Future<void> _onChangePreset(
      ChangePreset event, Emitter<TasbeehState> emit) async {
    await _storage.saveTasbeeh(0, 0, event.preset.name);
    emit(TasbeehLoaded(
        count: 0, total: 0, preset: event.preset, allPresets: _allPresets));
  }

  Future<void> _onAddCustomPreset(
      AddCustomPreset event, Emitter<TasbeehState> emit) async {
    await _storage.addCustomTasbeehPreset(event.preset);
    add(ChangePreset(event.preset));
  }
}
