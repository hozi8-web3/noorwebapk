import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/repositories/quran_repository.dart';
import 'data/repositories/prayer_times_repository.dart';
import 'data/repositories/hadith_repository.dart';
import 'data/services/quran_service.dart';
import 'data/services/prayer_times_service.dart';
import 'data/services/hadith_service.dart';
import 'data/storage/storage_service.dart';
import 'features/quran/bloc/quran_bloc.dart';
import 'features/prayer_times/bloc/prayer_times_bloc.dart';
import 'features/hadith/bloc/hadith_bloc.dart';
import 'features/tasbeeh/bloc/tasbeeh_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  final quranService = QuranService();
  final prayerTimesService = PrayerTimesService();
  final hadithService = HadithService();

  final quranRepo = QuranRepository(quranService, storageService);
  final prayerTimesRepo = PrayerTimesRepository(prayerTimesService, storageService);
  final hadithRepo = HadithRepository(hadithService, storageService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<QuranBloc>(
          create: (_) => QuranBloc(quranRepo)..add(LoadSurahList()),
        ),
        BlocProvider<PrayerTimesBloc>(
          create: (_) => PrayerTimesBloc(prayerTimesRepo, storageService)
            ..add(LoadPrayerTimes()),
        ),
        BlocProvider<HadithBloc>(
          create: (_) => HadithBloc(hadithRepo),
        ),
        BlocProvider<TasbeehBloc>(
          create: (_) => TasbeehBloc(storageService)..add(LoadTasbeeh()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(storageService)..add(LoadSettings()),
        ),
      ],
      child: NoorApp(isFirstLaunch: storageService.isFirstLaunch),
    ),
  );
}
