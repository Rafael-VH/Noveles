import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/utils/theme/dark_theme.dart';
import 'package:noveles/features/presentation/bloc/theme/theme_event.dart';
import 'package:noveles/features/presentation/bloc/theme/theme_state.dart';

// ThemeBloc es un Bloc que maneja los eventos y estados relacionados con el tema en la aplicación. Este Bloc reacciona a eventos como ThemeChanged para actualizar el estado del tema en la aplicación. En este caso, el Bloc emite un nuevo estado de ThemeState con la configuración del tema oscuro cada vez que se recibe un evento de cambio de tema. La interfaz de usuario puede reaccionar a los cambios en el estado del tema para actualizar la apariencia de la aplicación en consecuencia.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(DarkTheme.darkTheme)) {
    on<ThemeChanged>((event, emit) {
      emit(ThemeState(DarkTheme.darkTheme));
    });
  }
}
