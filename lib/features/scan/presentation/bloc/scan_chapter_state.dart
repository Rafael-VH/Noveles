import 'package:equatable/equatable.dart';

abstract class ScanChapterState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanChapterInitial extends ScanChapterState {}

class ScanChapterLoading extends ScanChapterState {}

class ScanChapterLoaded extends ScanChapterState {
  final String? message;
  ScanChapterLoaded({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class ScanChapterError extends ScanChapterState {
  final String message;
  ScanChapterError(this.message);
  @override
  List<Object> get props => [message];
}

class ScanChapterContentUploaded extends ScanChapterState {
  final String url;
  final String fileName;
  ScanChapterContentUploaded(this.url, {this.fileName = ''});
  @override
  List<Object> get props => [url, fileName];
}
