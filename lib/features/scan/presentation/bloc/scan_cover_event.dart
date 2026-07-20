import 'package:equatable/equatable.dart';

abstract class ScanCoverEvent extends Equatable {
  const ScanCoverEvent();

  @override
  List<Object> get props => [];
}

class UploadScanCover extends ScanCoverEvent {
  final String filePath;

  const UploadScanCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}
