part of 'prayer_times_bloc.dart';

abstract class PrayerTimesState {}

class PrayerTimesInitial extends PrayerTimesState {}
class PrayerTimesLoading extends PrayerTimesState {}
class PrayerTimesGpsLoading extends PrayerTimesState {}
class PrayerTimesError extends PrayerTimesState {
  final String message;
  PrayerTimesError(this.message);
}
class PrayerTimesGpsPermissionDenied extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimeModel prayerTimes;
  final String cityName;
  final bool isGps;
  final String? errorMessage;
  PrayerTimesLoaded(this.prayerTimes, this.cityName,
      {this.isGps = false, this.errorMessage});
}
