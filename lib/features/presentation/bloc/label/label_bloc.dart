import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
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
    final labels = await getLabels();
    final bookLabels = await getBookLabels();
    emit(LabelLoaded(labels, bookLabels, message: message));
  }

  Future<void> _onLoadLabels(LoadLabels event, Emitter<LabelState> emit) async {
    emit(const LabelLoading());
    try {
      await _emitLoaded(emit);
    } catch (e) {
      emit(LabelError(e.toString()));
    }
  }

  Future<void> _onCreateLabel(CreateLabelEvent event, Emitter<LabelState> emit) async {
    try {
      await createLabel(LabelEntity(
        id: 0, createdAt: DateTime.now(), name: event.name, color: event.color,
      ));
      await _emitLoaded(emit, message: 'Etiqueta creada');
    } catch (e) {
      emit(LabelError(e.toString()));
    }
  }

  Future<void> _onDeleteLabel(DeleteLabelEvent event, Emitter<LabelState> emit) async {
    try {
      await deleteLabel(event.id);
      await _emitLoaded(emit, message: 'Etiqueta eliminada');
    } catch (e) {
      emit(LabelError(e.toString()));
    }
  }

  Future<void> _onAssignLabel(AssignLabelEvent event, Emitter<LabelState> emit) async {
    try {
      await assignLabel(event.bookId, event.labelId);
      await _emitLoaded(emit, message: 'Etiqueta asignada');
    } catch (e) {
      emit(LabelError(e.toString()));
    }
  }

  Future<void> _onRemoveLabel(RemoveLabelEvent event, Emitter<LabelState> emit) async {
    try {
      await removeLabel(event.bookId, event.labelId);
      await _emitLoaded(emit, message: 'Etiqueta removida');
    } catch (e) {
      emit(LabelError(e.toString()));
    }
  }
}
