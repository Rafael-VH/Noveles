import 'package:equatable/equatable.dart';
import 'package:noveles/features/labels/domain/label_rule_entity.dart';

abstract class LabelRulesState extends Equatable {
  const LabelRulesState();

  @override
  List<Object?> get props => [];
}

class LabelRulesInitial extends LabelRulesState {
  const LabelRulesInitial();
}

class LabelRulesLoading extends LabelRulesState {
  const LabelRulesLoading();
}

class LabelRulesLoaded extends LabelRulesState {
  final List<LabelRuleEntity> rules;
  final String? message;

  const LabelRulesLoaded(this.rules, {this.message});

  @override
  List<Object?> get props => [rules, message];
}

class LabelRulesError extends LabelRulesState {
  final String message;

  const LabelRulesError(this.message);

  @override
  List<Object?> get props => [message];
}
