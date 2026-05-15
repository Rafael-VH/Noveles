import 'package:equatable/equatable.dart';

abstract class GenreEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadGenres extends GenreEvent {}
