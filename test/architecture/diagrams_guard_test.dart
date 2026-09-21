import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardia de la sección 8 del plan `docs/diagrams/PLAN-correccion-arquitectura.md`.
///
/// Los diagramas interactivos de `docs/diagrams/` describen la arquitectura con
/// texto plano (nombres de capas, rutas y clases). Cuando el código cambia, los
/// diagramas no se regeneran solos: esta guardia escanea el texto y falla si
/// vuelve a aparecer una afirmación que el código ya no cumple.
///
/// Límite honesto (anotado en el plan): el diagrama nombra capas, no rutas de
/// código; la guardia solo cubre lo que se enumera explícitamente en las listas
/// de abajo. Agregar un caso nuevo = agregar su string exacto a las listas.
void main() {
  final diagramsDir = Directory('docs/diagrams');
  final diagrams = <File>[];
  if (diagramsDir.existsSync()) {
    diagrams.addAll(
      diagramsDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.html') || f.path.endsWith('.svg')),
    );
  }

  test('el directorio docs/diagrams existe y contiene diagramas', () {
    expect(diagrams, isNotEmpty, reason: '¿Se movió docs/diagrams? Actualizá esta guardia.');
  });

  test('ningún diagrama afirma que Data conoce al vendor de Supabase', () {
    final prohibidos = <String, RegExp>{
      // La capa Data deja de conocer al vendor en el desacople (commit 397378f).
      'Data depende del cliente de Supabase': RegExp(r'Repos \+ Models · Supabase client'),
      'Data depende del cliente de Supabase (minúsculas)': RegExp(r'Repos \+ Models · supabase client', caseSensitive: false),
      // El intermediario borrado del código no puede volver a documentarse.
      'proveedor borrado SupabaseClientProvider': RegExp(r'SupabaseClientProvider'),
      'carpeta borrada lib/core/supabase': RegExp(r'lib/core/supabase'),
    };

    for (final file in diagrams) {
      final text = file.readAsStringSync();
      for (final entry in prohibidos.entries) {
        final match = entry.value.firstMatch(text);
        expect(
          match,
          isNull,
          reason: '${file.path} dice "${match?.group(0)}" (${entry.key}). '
              'El código ya no funciona así: actualizá el diagrama y, si el '
              'reemplazo es intencional, ajustá esta guardia.',
        );
      }
    }
  });

  test('los conteos de features en los diagramas coinciden con lib/features', () {
    final featuresDir = Directory('lib/features');
    final features = featuresDir.existsSync()
        ? featuresDir.listSync().whereType<Directory>().length
        : 0;
    expect(features, greaterThan(0), reason: '¿Se movió lib/features? Actualizá esta guardia.');

    final patron = RegExp(r'(\d+) features');
    for (final file in diagrams) {
      final text = file.readAsStringSync();
      for (final match in patron.allMatches(text)) {
        final declarado = int.parse(match.group(1)!);
        expect(
          declarado,
          features,
          reason: '${file.path} declara "$declarado features" pero '
              'lib/features tiene $features. Actualizá el diagrama.',
        );
      }
    }
  });
}
