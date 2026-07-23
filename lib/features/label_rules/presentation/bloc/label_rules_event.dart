import 'package:equatable/equatable.dart';

abstract class LabelRulesEvent extends Equatable {
  const LabelRulesEvent();

  @override
  List<Object?> get props => [];
}

class LoadLabelRules extends LabelRulesEvent {
  const LoadLabelRules();
}

class CreateLabelRule extends LabelRulesEvent {
  final int labelId;
  final String ruleType;
  final Map<String, dynamic> params;

  const CreateLabelRule({
    required this.labelId,
    required this.ruleType,
    required this.params,
  });

  @override
  List<Object?> get props => [labelId, ruleType, params];
}

class DeleteLabelRule extends LabelRulesEvent {
  final int ruleId;

  const DeleteLabelRule(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}
