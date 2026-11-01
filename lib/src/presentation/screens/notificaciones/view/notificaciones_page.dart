import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';

import '../cubit/notificaciones_cubit.dart';
import '../cubit/notificaciones_state.dart';
import 'notificaciones_content.dart';

class NotificacionesPage extends StatefulWidget {
  final bool citizen;

  const NotificacionesPage({super.key, this.citizen = false});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final _search = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _search.text = context.read<NotificacionesCubit>().state.search;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final session = context.read<SessionBloc>().state;
      final cubit = context.read<NotificacionesCubit>();

      cubit.bindSession(
        session.isAuthenticated
            ? session.session!.usuario.idUsuario.toString()
            : null,
      );

      unawaited(_refresh());
    });
  }

  Future<void> _refresh() async {
    final cubit = context.read<NotificacionesCubit>();

    await Future.wait([cubit.refresh(), cubit.refreshCount()]);
  }

  Future<void> _open(int id) async {
    final area = widget.citizen ? 'ciudadano' : 'operativo';

    await context.push('/notificaciones/$id?area=$area');

    if (mounted) {
      await _refresh();
    }
  }

  Future<void> _markAllRead() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar todas como leídas'),
        content: const Text(
          'Se marcarán todas las notificaciones disponibles, '
          'incluidas las de otras páginas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Marcar todas'),
          ),
        ],
      ),
    );

    if (!mounted || accepted != true) return;

    await context.read<NotificacionesCubit>().markAllRead();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificacionesCubit, NotificacionesState>(
      listenWhen: (previous, current) =>
          current.error != null && previous.error != current.error,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
      },
      builder: (context, state) {
        final cubit = context.read<NotificacionesCubit>();

        return NotificacionesContent(
          state: state,
          searchController: _search,
          onSearch: (value) {
            _debounce?.cancel();

            _debounce = Timer(const Duration(milliseconds: 400), () {
              if (mounted) {
                unawaited(cubit.setFilters(search: value));
              }
            });
          },
          onRefresh: _refresh,
          onLoadMore: cubit.loadMore,
          onArchived: (value) {
            unawaited(cubit.setFilters(archived: value));
          },
          onUnread: (value) {
            unawaited(cubit.setFilters(onlyUnread: value));
          },
          onOpen: _open,
          onRead: cubit.markRead,
          onArchive: cubit.archive,
          onReadAll: _markAllRead,
        );
      },
    );
  }
}
