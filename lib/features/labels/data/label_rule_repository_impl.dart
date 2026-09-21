import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/data/label_rule_model.dart';
import 'package:noveles/features/labels/domain/label_rule_entity.dart';
import 'package:noveles/features/labels/domain/label_rule_repository.dart';

class LabelRuleRepositoryImpl implements LabelRuleRepository {
  final DataGateway _data;

  LabelRuleRepositoryImpl(this._data);

  @override
  Future<Result<List<LabelRuleEntity>>> getRules() async {
    try {
      final rows = await _data.from('label_rules').order('id').rows();
      final rules =
          rows.map((json) => LabelRuleModel.fromJson(json)).toList();
      return Ok(rules);
    } catch (e) {
      return Err(LabelFailure('Error al obtener reglas', cause: e));
    }
  }

  @override
  Future<Result<void>> createRule({
    required int labelId,
    required String ruleType,
    required Map<String, dynamic> params,
  }) async {
    try {
      await _data.insert('label_rules', {
        'label_id': labelId,
        'rule_type': ruleType,
        'params': params,
      });
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al crear regla', cause: e));
    }
  }

  @override
  Future<Result<void>> updateRule({
    required int ruleId,
    required Map<String, dynamic> params,
  }) async {
    try {
      await _data.from('label_rules').eq('id', ruleId).update({
        'params': params,
      });
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al actualizar regla', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteRule(int ruleId) async {
    try {
      await _data.from('label_rules').eq('id', ruleId).delete();
      return const Ok(null);
    } catch (e) {
      return Err(LabelFailure('Error al eliminar regla', cause: e));
    }
  }
}
