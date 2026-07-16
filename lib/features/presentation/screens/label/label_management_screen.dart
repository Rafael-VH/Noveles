import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/utils/color_utils.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/widgets/label_badge.dart';

class LabelManagementScreen extends StatefulWidget {
  const LabelManagementScreen({super.key});

  @override
  State<LabelManagementScreen> createState() => _LabelManagementScreenState();
}

class _LabelManagementScreenState extends State<LabelManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LabelBloc>()..add(const LoadLabels()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gestionar Etiquetas')),
        body: BlocConsumer<LabelBloc, LabelState>(
          listener: (context, state) {
            if (state is LabelLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
            if (state is LabelError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is LabelLoading || state is LabelInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LabelLoaded) {
              return _LabelManagementContent(state: state);
            }
            if (state is LabelError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<LabelBloc>().add(const LoadLabels()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _LabelManagementContent extends StatefulWidget {
  final LabelLoaded state;
  const _LabelManagementContent({required this.state});

  @override
  State<_LabelManagementContent> createState() =>
      _LabelManagementContentState();
}

class _LabelManagementContentState extends State<_LabelManagementContent> {
  final _nameController = TextEditingController();
  String _selectedColor = ColorUtils.palette[0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.state.labels;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crear Etiqueta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ColorUtils.palette.map((hex) {
              final selected = _selectedColor == hex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ColorUtils.fromHex(hex),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              context
                  .read<LabelBloc>()
                  .add(CreateLabelEvent(name, _selectedColor));
              _nameController.clear();
            },
            child: const Text('Crear Etiqueta'),
          ),
          const Divider(height: 32),
          Text(
            'Etiquetas Existentes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (labels.isEmpty)
            const Text('No hay etiquetas')
          else
            ...labels.map(
              (label) => ListTile(
                leading: LabelBadge(name: label.name, color: label.color),
                title: Text(label.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () =>
                      context.read<LabelBloc>().add(DeleteLabelEvent(label.id)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
