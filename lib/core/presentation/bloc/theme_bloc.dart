import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/core/presentation/bloc/theme_event.dart';
export 'package:noveles/core/presentation/bloc/theme_state.dart';
import 'package:noveles/core/utils/theme/dark_theme.dart';
import 'package:noveles/core/utils/theme/light_theme.dart';
import 'package:noveles/core/presentation/bloc/theme_event.dart';
import 'package:noveles/core/presentation/bloc/theme_state.dart';

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
