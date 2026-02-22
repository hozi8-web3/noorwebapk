part of 'tasbeeh_bloc.dart';
abstract class TasbeehState {}
class TasbeehInitial extends TasbeehState {}
class TasbeehLoaded extends TasbeehState {
  final int count;
  final int total;
  final TasbeehPresetModel preset;
  final List<TasbeehPresetModel> allPresets;
  final bool cycleComplete;
  TasbeehLoaded({
    required this.count,
    required this.total,
    required this.preset,
    required this.allPresets,
    this.cycleComplete = false,
  });
}
