import 'package:equatable/equatable.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

abstract class ScanTookEvent extends Equatable {
  const ScanTookEvent();
  @override
  List<Object> get props => [];
}

class SaveScanTook extends ScanTookEvent {
  final TookEntity took;
  final bool isUpdate;
  const SaveScanTook(this.took, {required this.isUpdate});
  @override
  List<Object> get props => [took, isUpdate];
}

class DeleteScanTook extends ScanTookEvent {
  final int tookId;
  const DeleteScanTook(this.tookId);
  @override
  List<Object> get props => [tookId];
}

class UploadTookCover extends ScanTookEvent {
  final String filePath;
  const UploadTookCover(this.filePath);
  @override
  List<Object> get props => [filePath];
}
