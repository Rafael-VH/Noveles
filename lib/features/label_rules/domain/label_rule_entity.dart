import 'package:equatable/equatable.dart';

enum LabelRuleType {
  newRelease('new_release', 'Novedad'),
  mostRead('most_read', 'Más leídos'),
  mostPopular('most_popular', 'Más populares'),
  mostFavorited('most_favorited', 'Más favoritos');

  final String value;
  final String displayName;
  const LabelRuleType(this.value, this.displayName);

  static LabelRuleType fromString(String value) {
    return LabelRuleType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => LabelRuleType.newRelease,
    );
  }
}

class LabelRuleEntity extends Equatable {
  final int id;
  final int labelId;
  final LabelRuleType ruleType;
  final Map<String, dynamic> params;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LabelRuleEntity({
    required this.id,
    required this.labelId,
    required this.ruleType,
    this.params = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, labelId, ruleType, params, createdAt, updatedAt];
}
