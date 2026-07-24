import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_rule_repository.dart';

class DeleteRule {
  final LabelRuleRepository repository;
  DeleteRule(this.repository);

  Future<Result<void>> call(int ruleId) => repository.deleteRule(ruleId);
}
