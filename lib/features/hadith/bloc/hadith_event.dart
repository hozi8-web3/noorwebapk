part of 'hadith_bloc.dart';
abstract class HadithEvent {}
class LoadHadiths extends HadithEvent {
  final String edition;
  final String bookName;
  LoadHadiths(this.edition, this.bookName);
}
