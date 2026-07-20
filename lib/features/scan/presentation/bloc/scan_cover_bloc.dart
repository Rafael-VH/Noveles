import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/upload_image.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_event.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_state.dart';

export 'package:noveles/features/scan/presentation/bloc/scan_cover_event.dart';
export 'package:noveles/features/scan/presentation/bloc/scan_cover_state.dart';

class ScanCoverBloc extends Bloc<ScanCoverEvent, ScanCoverState> {
  final UploadImage uploadImage;

  ScanCoverBloc({
    required this.uploadImage,
  }) : super(ScanCoverInitial()) {
    on<UploadScanCover>(_onUploadCover);
  }

  Future<void> _onUploadCover(
    UploadScanCover event,
    Emitter<ScanCoverState> emit,
  ) async {
    emit(ScanCoverUploading());
    final result = await uploadImage(event.filePath);
    switch (result) {
      case Ok(:final value):
        emit(ScanCoverUploaded(value));
      case Err(:final error):
        emit(ScanCoverError(error.message));
    }
  }
}
