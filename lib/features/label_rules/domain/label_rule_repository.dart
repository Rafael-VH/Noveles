import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/label_rules/domain/label_rule_entity.dart';

abstract class LabelRuleRepository {
  Future<Result<List<LabelRuleEntity>>> getRules();
  Future<Result<void>> createRule({
    required int labelId,
    required String ruleType,
    required Map<String, dynamic> params,
  });
  Future<Result<void>> updateRule({
    required int ruleId,
    required Map<String, dynamic> params,
  });
  Future<Result<void>> deleteRule(int ruleId);
}
