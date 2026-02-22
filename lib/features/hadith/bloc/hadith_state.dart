part of 'hadith_bloc.dart';
abstract class HadithState {}
class HadithInitial extends HadithState {}
class HadithLoading extends HadithState {}
class HadithError extends HadithState {
  final String message;
  HadithError(this.message);
}
class HadithLoaded extends HadithState {
  final List<HadithModel> hadiths;
  final String bookName;
  HadithLoaded(this.hadiths, this.bookName);
}
