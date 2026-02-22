import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../data/models/prayer_time_model.dart';
import '../../../data/repositories/prayer_times_repository.dart';
import '../../../data/storage/storage_service.dart';

part 'prayer_times_event.dart';
part 'prayer_times_state.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  final PrayerTimesRepository _repo;
  final StorageService _storage;

  PrayerTimesBloc(this._repo, this._storage) : super(PrayerTimesInitial()) {
    on<LoadPrayerTimes>(_onLoad);
    on<LoadPrayerTimesByGPS>(_onLoadByGPS);
    on<ChangeCity>(_onChangeCity);
  }

  Future<void> _onLoad(
      LoadPrayerTimes event, Emitter<PrayerTimesState> emit) async {
    emit(PrayerTimesLoading());
    try {
      final times = await _repo.getPrayerTimes();
      emit(PrayerTimesLoaded(times, _storage.cityName));
    } catch (e) {
      emit(PrayerTimesError('Failed to load prayer times. Check connection.'));
    }
  }

  Future<void> _onLoadByGPS(
      LoadPrayerTimesByGPS event, Emitter<PrayerTimesState> emit) async {
    emit(PrayerTimesGpsLoading());
    try {
      // Check & request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(PrayerTimesGpsPermissionDenied());
        return;
      }

      // Get position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode to real city name
      String cityLabel = _coordLabel(pos.latitude, pos.longitude);
      try {
        final placemarks = await placemarkFromCoordinates(
          pos.latitude, pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          // Build: "City, Country"
          final parts = <String>[];
          if (p.locality != null && p.locality!.isNotEmpty) {
            parts.add(p.locality!);
          } else if (p.subAdministrativeArea != null &&
              p.subAdministrativeArea!.isNotEmpty) {
            parts.add(p.subAdministrativeArea!);
          }
          if (p.country != null && p.country!.isNotEmpty) {
            parts.add(p.country!);
          }
          if (parts.isNotEmpty) cityLabel = parts.join(', ');
        }
      } catch (_) {
        // Geocoding failed — use coordinate label as fallback
      }

      final times = await _repo.getPrayerTimesByLocation(
          pos.latitude, pos.longitude, cityLabel);
      emit(PrayerTimesLoaded(times, cityLabel, isGps: true));
    } catch (e) {
      // Try loading from cached/default city
      try {
        final times = await _repo.getPrayerTimes();
        emit(PrayerTimesLoaded(times, _storage.cityName,
            errorMessage: 'GPS failed — using saved city'));
      } catch (_) {
        emit(PrayerTimesError(
            'GPS unavailable: ${e.toString().split('\n').first}'));
      }
    }
  }

  Future<void> _onChangeCity(
      ChangeCity event, Emitter<PrayerTimesState> emit) async {
    emit(PrayerTimesLoading());
    try {
      final times =
          await _repo.getPrayerTimesForCity(event.city, event.country);
      emit(PrayerTimesLoaded(times, event.city));
    } catch (e) {
      emit(PrayerTimesError('Could not load times for ${event.city}.'));
    }
  }

  String _coordLabel(double lat, double lon) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(1)}°$latDir, '
        '${lon.abs().toStringAsFixed(1)}°$lonDir';
  }
}
