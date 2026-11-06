import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_cubit.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';

class NotificationsBell extends StatelessWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificacionesCubit, NotificacionesState>(
      buildWhen: (previous, current) =>
          previous.unread != current.unread ||
          previous.userId != current.userId,
      builder: (context, state) {
        return IconButton(
          tooltip: 'Notificaciones: ${state.unread} sin leer',
          onPressed: state.userId == null
              ? null
              : () {
                  final session = context.read<SessionBloc>().state;

                  final roles = getSessionRoles(session);
                  final path = GoRouterState.of(context).uri.path;

                  final citizen =
                      path.startsWith('/ciudadano/') ||
                      (roles.contains('CIUDADANO') &&
                          !roles.any(operationalRoles.contains));

                  context.push(
                    citizen ? '/ciudadano/alertas' : '/notificaciones',
                  );
                },
          icon: Badge(
            isLabelVisible: state.unread > 0,
            label: Text(state.unread > 99 ? '99+' : '${state.unread}'),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}
