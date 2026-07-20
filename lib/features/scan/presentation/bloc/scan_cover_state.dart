import 'package:equatable/equatable.dart';

abstract class ScanCoverState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanCoverInitial extends ScanCoverState {}

class ScanCoverUploading extends ScanCoverState {}

class ScanCoverUploaded extends ScanCoverState {
  final String filename;

  ScanCoverUploaded(this.filename);

  @override
  List<Object> get props => [filename];
}

class ScanCoverError extends ScanCoverState {
  final String message;

  ScanCoverError(this.message);

  @override
  List<Object> get props => [message];
}
