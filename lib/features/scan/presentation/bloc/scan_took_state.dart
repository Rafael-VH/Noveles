import 'package:equatable/equatable.dart';

abstract class ScanTookState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanTookInitial extends ScanTookState {}

class ScanTookLoading extends ScanTookState {}

class ScanTookLoaded extends ScanTookState {
  final String? message;
  ScanTookLoaded({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class ScanTookError extends ScanTookState {
  final String message;
  ScanTookError(this.message);
  @override
  List<Object> get props => [message];
}

class ScanTookCoverUploaded extends ScanTookState {
  final String url;
  ScanTookCoverUploaded(this.url);
  @override
  List<Object> get props => [url];
}
