import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/widgets/app_drawer.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(const LoadAdminBooks()),
      child: Scaffold(
        drawer: const AppDrawer(isAdmin: true),
        appBar: AppBar(title: const Text('Panel Admin')),
        body: BlocConsumer<AdminBloc, AdminState>(
          // Listener para mostrar mensajes de éxito o error según el estado del AdminBloc
          listener: (context, state) {
            // Mostrar mensajes de éxito o error según el estado del AdminBloc
            if (state is AdminLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            }

            // Mostrar errores en un SnackBar si el estado es AdminError
            if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },

          // Builder para construir la interfaz de usuario según el estado del AdminBloc
          builder: (context, state) {
            // Mostrar un indicador de carga mientras se están cargando los libros
            if (state is AdminLoading || state is AdminInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Mostrar la lista de libros y estadísticas cuando se hayan cargado los datos correctamente
            if (state is AdminLoaded) {
              return _buildContent(context, state);
            }

            // Mostrar un mensaje de error si el estado es AdminError
            if (state is AdminError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mostrar el mensaje de error específico del estado AdminError
                    Text(state.message),

                    const SizedBox(height: 16),

                    // Botón para reintentar cargar los libros, que envía el evento LoadAdminBooks al AdminBloc
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AdminBloc>().add(const LoadAdminBooks()),
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

  // Método privado para construir el contenido principal del panel de administración, que muestra estadísticas y la lista de libros con opciones para alternar su visibilidad
  Widget _buildContent(BuildContext context, AdminLoaded state) {
    final total = state.books.length;
    final visible = state.books.where((b) => b.isVisible).length;

    return Column(
      children: [
        // Tarjeta que muestra estadísticas de libros visibles y total de libros en el panel de administración
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Mostrar estadísticas de libros visibles y total de libros, con íconos y texto para cada uno
                  Row(
                    children: [
                      // Ícono de visibilidad
                      Icon(
                        Icons.visibility,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(width: 8),

                      // Mostrar el número de libros visibles en el panel de administración
                      Text('Visibles: $visible'),
                    ],
                  ),

                  // Separador entre las estadísticas de libros visibles y total de libros
                  Row(
                    children: [
                      // Ícono de libro para representar el total de libros
                      Icon(
                        Icons.menu_book,
                        color: Theme.of(context).colorScheme.secondary,
                      ),

                      const SizedBox(width: 8),

                      // Mostrar el número total de libros en el panel de administración
                      Text('Total: $total'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LabelManagementScreen()),
            ),
            icon: const Icon(Icons.label),
            label: const Text('Gestionar Etiquetas'),
          ),
        ),
        const SizedBox(height: 8),
        // Listado de libros con opciones para alternar su visibilidad, envía el evento ToggleBookVisibility al AdminBloc cuando se presiona el botón de visibilidad
        Expanded(
          child: RefreshIndicator(
            // Función para refrescar la lista de libros, que envía el evento LoadAdminBooks al AdminBloc y espera a que se carguen los datos antes de finalizar el refresco
            onRefresh: () async {
              context.read<AdminBloc>().add(const LoadAdminBooks());
              await context.read<AdminBloc>().stream.firstWhere(
                    (s) => s is AdminLoaded || s is AdminError,
                  );
            },

            // Mostrar un mensaje si no hay libros en el panel de administración, o una lista de libros con opciones para alternar su visibilidad si hay libros disponibles
            child: state.books.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(
                        height: 200,
                        child: Center(child: Text('No hay libros')),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: state.books.length,
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            width: 48,
                            height: 64,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: coverUrl(book.cover),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.book,
                                size: 48,
                              ),
                            ),
                          ),
                          title: Text(
                            book.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              // Mostrar el nombre del autor del libro, con un ícono que indica si el libro es visible u oculto, y texto que muestra el estado de visibilidad del libro (Visible u Oculto) con colores correspondientes
                              Expanded(
                                child: Text(
                                  book.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Ícono que indica si el libro es visible u oculto, con un color verde para visible y rojo para oculto
                              Icon(
                                book.isVisible
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: book.isVisible ? Colors.green : Colors.red,
                              ),

                              const SizedBox(width: 4),

                              // Texto que muestra el estado de visibilidad del libro (Visible u Oculto) con colores correspondientes, para indicar claramente si el libro está publicado o no en el panel de administración
                              Text(
                                book.isVisible ? 'Visible' : 'Oculto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: book.isVisible
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              book.isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            // Al presionar el botón de visibilidad, se envía el evento ToggleBookVisibility al AdminBloc con el ID del libro y su nueva visibilidad (alternando entre visible y oculto)
                            onPressed: () {
                              context.read<AdminBloc>().add(
                                    ToggleBookVisibility(
                                        book.id, !book.isVisible),
                                  );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
