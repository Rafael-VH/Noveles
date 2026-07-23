import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/label_rules/domain/label_rule_entity.dart';
import 'package:noveles/features/label_rules/domain/label_rule_repository.dart';

class GetRules {
  final LabelRuleRepository repository;
  GetRules(this.repository);

  Future<Result<List<LabelRuleEntity>>> call() => repository.getRules();
}
