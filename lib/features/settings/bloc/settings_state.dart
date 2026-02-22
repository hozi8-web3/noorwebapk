part of 'settings_bloc.dart';
abstract class SettingsState {}
class SettingsInitial extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final bool isDarkMode;
  SettingsLoaded(this.isDarkMode);
}
