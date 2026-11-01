import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_cubit.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CiudadanoBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CiudadanoBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: colors.surface,
        indicatorColor: colors.secondaryContainer,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: BlocBuilder<NotificacionesCubit, NotificacionesState>(
              builder: (_, state) => Badge(
                isLabelVisible: state.unread > 0,
                label: Text(state.unread > 99 ? '99+' : '${state.unread}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
            selectedIcon: BlocBuilder<NotificacionesCubit, NotificacionesState>(
              builder: (_, state) => Badge(
                isLabelVisible: state.unread > 0,
                label: Text(state.unread > 99 ? '99+' : '${state.unread}'),
                child: const Icon(Icons.notifications_rounded),
              ),
            ),
            label: 'Alertas',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.notifications_outlined),
          //   selectedIcon: Icon(Icons.notifications_rounded),
          //   label: 'Alertas',
          // ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Mi cuenta',
          ),
        ],
      ),
    );
  }
}
