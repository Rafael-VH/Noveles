import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/label_rules/domain/label_rule_repository.dart';

class UpdateRule {
  final LabelRuleRepository repository;
  UpdateRule(this.repository);

  Future<Result<void>> call({
    required int ruleId,
    required Map<String, dynamic> params,
  }) {
    return repository.updateRule(ruleId: ruleId, params: params);
  }
}
