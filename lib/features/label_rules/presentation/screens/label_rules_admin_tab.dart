import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/label_rules/domain/label_rule_entity.dart';
import 'package:noveles/features/label_rules/presentation/bloc/label_rules_bloc.dart';
import 'package:noveles/features/label_rules/presentation/bloc/label_rules_event.dart';
import 'package:noveles/features/label_rules/presentation/bloc/label_rules_state.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/get_labels.dart';

class LabelRulesAdminTab extends StatefulWidget {
  const LabelRulesAdminTab({super.key});

  @override
  State<LabelRulesAdminTab> createState() => _LabelRulesAdminTabState();
}

class _LabelRulesAdminTabState extends State<LabelRulesAdminTab> {
  late final GetLabels _getLabels;

  @override
  void initState() {
    super.initState();
    _getLabels = getIt<GetLabels>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LabelRulesBloc>()..add(const LoadLabelRules()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reglas de Etiquetas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Nueva Regla',
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        body: BlocConsumer<LabelRulesBloc, LabelRulesState>(
          listener: (context, state) {
            if (state is LabelRulesLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
            if (state is LabelRulesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is LabelRulesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LabelRulesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is LabelRulesLoaded) {
              if (state.rules.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rule, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Sin reglas aún',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agregá una regla para auto-asignar etiquetas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<LabelRulesBloc>().add(const LoadLabelRules());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.rules.length,
                  itemBuilder: (context, index) {
                    final rule = state.rules[index];
                    return _RuleCard(rule: rule, onDelete: () => _confirmDelete(context, rule));
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LabelRuleEntity rule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Regla'),
        content: Text('¿Eliminar regla "${rule.ruleType.displayName}" para etiqueta #${rule.labelId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LabelRulesBloc>().add(DeleteLabelRule(rule.id));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final labelsResult = await _getLabels();
    if (!context.mounted) return;

    List<LabelEntity> labels;
    switch (labelsResult) {
      case Ok(value: final v):
        labels = v;
      case Err():
        labels = [];
    }

    if (labels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay etiquetas disponibles. Creá etiquetas primero.')),
      );
      return;
    }

    final selectedLabel = ValueNotifier<LabelEntity?>(labels.first);
    final ruleType = ValueNotifier<LabelRuleType>(LabelRuleType.newRelease);
    final limitController = TextEditingController(text: '10');
    final daysController = TextEditingController(text: '30');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Regla'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Etiqueta:'),
              ValueListenableBuilder<LabelEntity?>(
                valueListenable: selectedLabel,
                builder: (context, label, _) => DropdownButton<LabelEntity>(
                  isExpanded: true,
                  value: label,
                  items: labels
                      .map(
                        (l) => DropdownMenuItem(value: l, child: Text(l.name)),
                      )
                      .toList(),
                  onChanged: (v) => selectedLabel.value = v,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tipo de Regla:'),
              ValueListenableBuilder<LabelRuleType>(
                valueListenable: ruleType,
                builder: (context, type, _) => DropdownButton<LabelRuleType>(
                  isExpanded: true,
                  value: type,
                  items: LabelRuleType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.displayName)),
                      )
                      .toList(),
                  onChanged: (v) => ruleType.value = v!,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<LabelRuleType>(
                valueListenable: ruleType,
                builder: (context, type, _) {
                  if (type == LabelRuleType.newRelease) {
                    return TextField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Días desde publicación',
                      ),
                    );
                  }
                  return TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de libros',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final label = selectedLabel.value;
              final type = ruleType.value;
              if (label == null) return;

              final params = type == LabelRuleType.newRelease
                  ? {'days_since': int.tryParse(daysController.text) ?? 30}
                  : {'limit': int.tryParse(limitController.text) ?? 10};

              context.read<LabelRulesBloc>().add(CreateLabelRule(
                    labelId: label.id,
                    ruleType: type.value,
                    params: params,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final LabelRuleEntity rule;
  final VoidCallback onDelete;

  const _RuleCard({required this.rule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _ruleIcon(rule.ruleType),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.ruleType.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Etiqueta #${rule.labelId} — ${_paramsSummary(rule.params)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: theme.colorScheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  IconData _ruleIcon(LabelRuleType type) {
    switch (type) {
      case LabelRuleType.newRelease:
        return Icons.new_releases;
      case LabelRuleType.mostRead:
        return Icons.visibility;
      case LabelRuleType.mostPopular:
        return Icons.trending_up;
      case LabelRuleType.mostFavorited:
        return Icons.favorite;
    }
  }

  String _paramsSummary(Map<String, dynamic> params) {
    if (params.containsKey('days_since')) {
      return 'publicados en últimos ${params['days_since']} días';
    }
    if (params.containsKey('limit')) {
      return 'top ${params['limit']} libros';
    }
    return params.toString();
  }
}
