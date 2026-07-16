import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/utils/theme/dark_theme.dart';
import 'package:noveles/core/utils/theme/light_theme.dart';
import 'package:noveles/features/presentation/bloc/theme/theme_event.dart';
import 'package:noveles/features/presentation/bloc/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(
          isDarkMode: true, themeData: DarkTheme.darkTheme)) {
    on<ThemeChanged>((event, emit) {
      emit(ThemeState(
        isDarkMode: event.isDarkMode,
        themeData:
            event.isDarkMode ? DarkTheme.darkTheme : LightTheme.lightTheme,
      ));
    });
  }
}
