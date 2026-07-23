import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/label_rules/domain/label_rule_repository.dart';

class CreateRule {
  final LabelRuleRepository repository;
  CreateRule(this.repository);

  Future<Result<void>> call({
    required int labelId,
    required String ruleType,
    required Map<String, dynamic> params,
  }) {
    return repository.createRule(labelId: labelId, ruleType: ruleType, params: params);
  }
}
