part of 'settings_bloc.dart';
abstract class SettingsEvent {}
class LoadSettings extends SettingsEvent {}
class ToggleTheme extends SettingsEvent {}
