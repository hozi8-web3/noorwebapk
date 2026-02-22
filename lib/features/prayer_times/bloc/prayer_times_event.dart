part of 'prayer_times_bloc.dart';

abstract class PrayerTimesEvent {}

class LoadPrayerTimes extends PrayerTimesEvent {}

class LoadPrayerTimesByGPS extends PrayerTimesEvent {}

class ChangeCity extends PrayerTimesEvent {
  final String city;
  final String country;
  ChangeCity(this.city, this.country);
}
