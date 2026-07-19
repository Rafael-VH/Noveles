import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/labels/data/label_repository_impl.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';
import 'package:noveles/features/labels/domain/create_label.dart';
import 'package:noveles/features/labels/domain/get_labels.dart';
import 'package:noveles/features/labels/domain/update_label.dart';
import 'package:noveles/features/labels/domain/delete_label.dart';
import 'package:noveles/features/labels/domain/assign_label_to_book.dart';
import 'package:noveles/features/labels/domain/remove_label_from_book.dart';
import 'package:noveles/features/labels/domain/get_labels_for_books.dart';
import 'package:noveles/features/labels/presentation/bloc/label_bloc.dart';

final getIt = GetIt.instance;

void initLabelsDependencies() {
  getIt.registerLazySingleton<LabelRepository>(
    () => LabelRepositoryImpl(
      getIt<SupabaseClientProvider>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetLabels(getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateLabel(getIt()),
  );
  getIt.registerLazySingleton(
    () => DeleteLabel(getIt()),
  );
  getIt.registerLazySingleton(
    () => AssignLabelToBook(getIt()),
  );
  getIt.registerLazySingleton(
    () => RemoveLabelFromBook(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateLabel(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetLabelsForBooks(getIt()),
  );

  getIt.registerFactory(
    () => LabelBloc(
      getLabels: getIt(),
      createLabel: getIt(),
      deleteLabel: getIt(),
      assignLabel: getIt(),
      removeLabel: getIt(),
      getLabelsForBooks: getIt(),
    ),
  );
}
