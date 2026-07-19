import 'package:equatable/equatable.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

abstract class ScanTookEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveScanTook extends ScanTookEvent {
  final TookEntity took;
  final bool isUpdate;
  SaveScanTook(this.took, {required this.isUpdate});
  @override
  List<Object> get props => [took, isUpdate];
}

class DeleteScanTook extends ScanTookEvent {
  final int tookId;
  DeleteScanTook(this.tookId);
  @override
  List<Object> get props => [tookId];
}

class UploadTookCover extends ScanTookEvent {
  final String filePath;
  UploadTookCover(this.filePath);
  @override
  List<Object> get props => [filePath];
}
