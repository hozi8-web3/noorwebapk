import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/theme/app_theme.dart';
import '../features/settings/bloc/settings_bloc.dart';
import '../shared/navigation/main_scaffold.dart';
import '../features/landing/landing_screen.dart';

class NoorApp extends StatelessWidget {
  final bool isFirstLaunch;
  const NoorApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.system;
        if (state is SettingsLoaded) {
          themeMode = state.isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }
        return MaterialApp(
          title: 'NoorWeb',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: isFirstLaunch ? const LandingScreen() : const MainScaffold(),
          routes: {
            '/home': (_) => const MainScaffold(),
          },
        );
      },
    );
  }
}
