part of 'tasbeeh_bloc.dart';
abstract class TasbeehEvent {}
class LoadTasbeeh extends TasbeehEvent {}
class IncrementTasbeeh extends TasbeehEvent {}
class ResetTasbeeh extends TasbeehEvent {}
class ChangePreset extends TasbeehEvent {
  final TasbeehPresetModel preset;
  ChangePreset(this.preset);
}
class AddCustomPreset extends TasbeehEvent {
  final TasbeehPresetModel preset;
  AddCustomPreset(this.preset);
}
