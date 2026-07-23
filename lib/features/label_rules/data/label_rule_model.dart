import 'package:noveles/features/label_rules/domain/label_rule_entity.dart';

class LabelRuleModel extends LabelRuleEntity {
  const LabelRuleModel({
    required super.id,
    required super.labelId,
    required super.ruleType,
    required super.params,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LabelRuleModel.fromJson(Map<String, dynamic> json) {
    return LabelRuleModel(
      id: json['id'] as int,
      labelId: json['label_id'] as int,
      ruleType: LabelRuleType.fromString(json['rule_type'] as String? ?? ''),
      params: json['params'] is Map ? Map<String, dynamic>.from(json['params']) : {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
