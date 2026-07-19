import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/create_took.dart';
import 'package:noveles/features/tooks/domain/update_took.dart';
import 'package:noveles/features/tooks/domain/delete_took.dart';
import 'package:noveles/features/books/domain/upload_cover.dart';

// Events
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

// States
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

// BLoC
class ScanTookBloc extends Bloc<ScanTookEvent, ScanTookState> {
  final CreateTook createTook;
  final UpdateTook updateTook;
  final DeleteTook deleteTook;
  final UploadCover uploadCover;

  ScanTookBloc({
    required this.createTook,
    required this.updateTook,
    required this.deleteTook,
    required this.uploadCover,
  }) : super(ScanTookInitial()) {
    on<SaveScanTook>(_onSaveTook);
    on<DeleteScanTook>(_onDeleteTook);
    on<UploadTookCover>(_onUploadCover);
  }

  Future<void> _onSaveTook(SaveScanTook event, Emitter<ScanTookState> emit) async {
    emit(ScanTookLoading());
    final result = event.isUpdate ? await updateTook(event.took) : await createTook(event.took);
    switch (result) {
      case Ok():
        emit(ScanTookLoaded(message: event.isUpdate ? 'Tomo guardado' : 'Tomo creado'));
      case Err(:final error):
        emit(ScanTookError(error.message));
    }
  }

  Future<void> _onDeleteTook(DeleteScanTook event, Emitter<ScanTookState> emit) async {
    emit(ScanTookLoading());
    final result = await deleteTook(event.tookId);
    switch (result) {
      case Ok():
        emit(ScanTookLoaded(message: 'Tomo eliminado'));
      case Err(:final error):
        emit(ScanTookError(error.message));
    }
  }

  Future<void> _onUploadCover(UploadTookCover event, Emitter<ScanTookState> emit) async {
    final result = await uploadCover(event.filePath);
    switch (result) {
      case Ok(:final value):
        emit(ScanTookCoverUploaded(value));
      case Err(:final error):
        emit(ScanTookError(error.message));
    }
  }
}
