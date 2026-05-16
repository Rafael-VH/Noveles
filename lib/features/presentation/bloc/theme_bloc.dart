import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/utils/theme/theme.dart';
import 'package:noveles/features/presentation/bloc/theme_event.dart';
import 'package:noveles/features/presentation/bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(LightTheme.lightTheme)) {
    on<ThemeChanged>((event, emit) {
      if (event.isDarkMode) {
        emit(ThemeState(DarkTheme.darkTheme));
      } else {
        emit(ThemeState(LightTheme.lightTheme));
      }
    });
  }
}
