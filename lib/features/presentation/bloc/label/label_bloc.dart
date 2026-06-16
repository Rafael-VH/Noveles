import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/get_labels.dart';
import 'package:noveles/features/labels/domain/create_label.dart';
import 'package:noveles/features/labels/domain/delete_label.dart';
import 'package:noveles/features/labels/domain/assign_label_to_book.dart';
import 'package:noveles/features/labels/domain/remove_label_from_book.dart';
import 'package:noveles/features/books/domain/get_book_labels.dart';
import 'package:noveles/features/presentation/bloc/label/label_event.dart';
import 'package:noveles/features/presentation/bloc/label/label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  final GetLabels getLabels;
  final CreateLabel createLabel;
  final DeleteLabel deleteLabel;
  final AssignLabelToBook assignLabel;
  final RemoveLabelFromBook removeLabel;
  final GetBookLabels getBookLabels;

  LabelBloc({
    required this.getLabels,
    required this.createLabel,
    required this.deleteLabel,
    required this.assignLabel,
    required this.removeLabel,
    required this.getBookLabels,
  }) : super(const LabelInitial()) {
    on<LoadLabels>(_onLoadLabels);
    on<CreateLabelEvent>(_onCreateLabel);
    on<DeleteLabelEvent>(_onDeleteLabel);
    on<AssignLabelEvent>(_onAssignLabel);
    on<RemoveLabelEvent>(_onRemoveLabel);
  }

  Future<void> _emitLoaded(Emitter<LabelState> emit, {String? message}) async {
    final labelsResult = await getLabels();
    switch (labelsResult) {
      case Ok(:final value):
        final loadedLabels = value;
        final bookLabelsResult = await getBookLabels();
        switch (bookLabelsResult) {
          case Ok(:final value):
            emit(LabelLoaded(loadedLabels, value, message: message));
          case Err(:final error):
            NotificationService.error(
                'Error al actualizar las etiquetas de libros: ${error.message}');
        }
      case Err(:final error):
        NotificationService.error(
            'Error al actualizar las etiquetas: ${error.message}');
    }
  }

  Future<void> _onLoadLabels(LoadLabels event, Emitter<LabelState> emit) async {
    emit(const LabelLoading());
    final labelsResult = await getLabels();
    switch (labelsResult) {
      case Ok(:final value):
        final loadedLabels = value;
        final bookLabelsResult = await getBookLabels();
        switch (bookLabelsResult) {
          case Ok(:final value):
            emit(LabelLoaded(loadedLabels, value));
          case Err(:final error):
            emit(LabelError(error.message));
            NotificationService.error(
                'Error al cargar etiquetas de libros: ${error.message}');
        }
      case Err(:final error):
        emit(LabelError(error.message));
        NotificationService.error('Error al cargar etiquetas: ${error.message}');
    }
  }

  Future<void> _onCreateLabel(
      CreateLabelEvent event, Emitter<LabelState> emit) async {
    final result = await createLabel(LabelEntity(
      id: 0,
      createdAt: DateTime.now(),
      name: event.name,
      color: event.color,
    ));
    switch (result) {
      case Ok():
        await _emitLoaded(emit, message: 'Etiqueta creada');
      case Err(:final error):
        emit(LabelError(error.message));
        NotificationService.error('Error al crear la etiqueta: ${error.message}');
    }
  }

  Future<void> _onDeleteLabel(
      DeleteLabelEvent event, Emitter<LabelState> emit) async {
    final result = await deleteLabel(event.id);
    switch (result) {
      case Ok():
        await _emitLoaded(emit, message: 'Etiqueta eliminada');
      case Err(:final error):
        emit(LabelError(error.message));
        NotificationService.error(
            'Error al eliminar la etiqueta: ${error.message}');
    }
  }

  Future<void> _onAssignLabel(
      AssignLabelEvent event, Emitter<LabelState> emit) async {
    final result = await assignLabel(event.bookId, event.labelId);
    switch (result) {
      case Ok():
        await _emitLoaded(emit, message: 'Etiqueta asignada');
      case Err(:final error):
        emit(LabelError(error.message));
        NotificationService.error(
            'Error al asignar la etiqueta: ${error.message}');
    }
  }

  Future<void> _onRemoveLabel(
      RemoveLabelEvent event, Emitter<LabelState> emit) async {
    final result = await removeLabel(event.bookId, event.labelId);
    switch (result) {
      case Ok():
        await _emitLoaded(emit, message: 'Etiqueta removida');
      case Err(:final error):
        emit(LabelError(error.message));
        NotificationService.error(
            'Error al remover la etiqueta: ${error.message}');
    }
  }
}
