import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/label_rules/domain/get_rules.dart';
import 'package:noveles/features/label_rules/domain/create_rule.dart';
import 'package:noveles/features/label_rules/domain/delete_rule.dart';
import 'package:noveles/features/label_rules/presentation/bloc/label_rules_event.dart';
import 'package:noveles/features/label_rules/presentation/bloc/label_rules_state.dart';

class LabelRulesBloc extends Bloc<LabelRulesEvent, LabelRulesState> {
  final GetRules getRules;
  final CreateRule createRule;
  final DeleteRule deleteRule;

  LabelRulesBloc({
    required this.getRules,
    required this.createRule,
    required this.deleteRule,
  }) : super(const LabelRulesInitial()) {
    on<LoadLabelRules>(_onLoad);
    on<CreateLabelRule>(_onCreate);
    on<DeleteLabelRule>(_onDelete);
  }

  Future<void> _onLoad(LoadLabelRules event, Emitter<LabelRulesState> emit) async {
    emit(const LabelRulesLoading());
    final result = await getRules();
    switch (result) {
      case Ok(:final value):
        emit(LabelRulesLoaded(value));
      case Err(:final error):
        emit(LabelRulesError(error.message));
    }
  }

  Future<void> _onCreate(CreateLabelRule event, Emitter<LabelRulesState> emit) async {
    final result = await createRule(
      labelId: event.labelId,
      ruleType: event.ruleType,
      params: event.params,
    );
    switch (result) {
      case Ok():
        add(const LoadLabelRules());
      case Err(:final error):
        if (state is LabelRulesLoaded) {
          emit(LabelRulesLoaded((state as LabelRulesLoaded).rules, message: error.message));
        } else {
          emit(LabelRulesError(error.message));
        }
    }
  }

  Future<void> _onDelete(DeleteLabelRule event, Emitter<LabelRulesState> emit) async {
    final result = await deleteRule(event.ruleId);
    switch (result) {
      case Ok():
        add(const LoadLabelRules());
      case Err(:final error):
        if (state is LabelRulesLoaded) {
          emit(LabelRulesLoaded((state as LabelRulesLoaded).rules, message: error.message));
        } else {
          emit(LabelRulesError(error.message));
        }
    }
  }
}
