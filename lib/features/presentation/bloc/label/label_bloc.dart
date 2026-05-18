import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/label/label_event.dart';
import 'package:noveles/features/presentation/bloc/label/label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  final GetLabels getLabels;
  final CreateLabel createLabel;
  final DeleteLabel deleteLabel;
  final AssignLabelToBook assignLabel;
  final RemoveLabelFromBook removeLabel;

  LabelBloc({
    required this.getLabels,
    required this.createLabel,
    required this.deleteLabel,
    required this.assignLabel,
    required this.removeLabel,
  }) : super(LabelInitial()) {
    on<LoadLabels>(_onLoadLabels);
    on<CreateLabelEvent>(_onCreateLabel);
    on<DeleteLabelEvent>(_onDeleteLabel);
    on<AssignLabelEvent>(_onAssignLabel);
    on<RemoveLabelEvent>(_onRemoveLabel);
  }

  Future<Map<int, Set<int>>> _fetchBookLabels() async {
    final rows = await supabase.from('books_labels').select();
    final map = <int, Set<int>>{};
    for (final row in rows) {
      map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
    }
    return map;
  }

  Future<void> _emitLoaded(Emitter<LabelState> emit, {String? message}) async {
    final labels = await getLabels();
    final bookLabels = await _fetchBookLabels();
    emit(LabelLoaded(labels, bookLabels, message: message));
  }

  Future<void> _onLoadLabels(LoadLabels event, Emitter<LabelState> emit) async {
    emit(LabelLoading());
    try {
      await _emitLoaded(emit);
    } catch (e) {
      emit(LabelError(e.toString()));
    }
  }

  Future<void> _onCreateLabel(CreateLabelEvent event, Emitter<LabelState> emit) async {
    try {
      await createLabel(event.name, event.color);
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
