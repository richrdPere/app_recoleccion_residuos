import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_cubit.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/cubit/notificaciones_state.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/view/notificaciones_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/injection.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_state.dart';
import 'package:app_recoleccion_residuos/src/config/router/auth_redirect.dart';
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class NotificacionDetallePage extends StatefulWidget {
  final int id;
  final bool citizen;

  const NotificacionDetallePage({
    super.key,
    required this.id,
    this.citizen = false,
  });

  @override
  State<NotificacionDetallePage> createState() =>
      _NotificacionDetallePageState();
}

class _NotificacionDetallePageState extends State<NotificacionDetallePage> {
  GetNotificacionByIdDataModel? _item;

  String? _error;

  bool _loading = true;
  bool _readConfirmed = false;

  int _request = 0;

  String? get _userId {
    final session = context.read<SessionBloc>().state;

    return session.isAuthenticated
        ? session.session!.usuario.idUsuario.toString()
        : null;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void didUpdateWidget(covariant NotificacionDetallePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id) {
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++_request;
    final userId = _userId;

    if (userId == null || widget.id <= 0) {
      setState(() {
        _item = null;
        _loading = false;
        _error = 'No se puede abrir esta notificación.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _item = null;
      _error = null;
      _readConfirmed = false;
    });

    try {
      final result = await locator<NotificacionesUseCases>().getNotificacionById
          .run(id: widget.id);

      if (!mounted || request != _request || _userId != userId) {
        return;
      }

      if (result is! Success<ApiResponse<GetNotificacionByIdDataModel>>) {
        throw StateError(
          result is ErrorData<ApiResponse<GetNotificacionByIdDataModel>>
              ? result.message
              : 'No se pudo consultar la notificación.',
        );
      }

      final item = result.data.data;

      if (item == null || item.idUsuario.toString() != userId) {
        throw StateError(
          'La notificación no está disponible para esta cuenta.',
        );
      }

      setState(() {
        _item = item;
        _readConfirmed = item.leida;
        _loading = false;
      });

      if (!item.leida) {
        await _markRead(expectedUser: userId, expectedRequest: request);
      }
    } catch (error) {
      if (!mounted || request != _request || _userId != userId) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error is StateError
            ? error.message.toString()
            : 'No se pudo cargar el detalle.';
      });
    }
  }

  Future<void> _markRead({
    required String expectedUser,
    required int expectedRequest,
  }) async {
    final cubit = context.read<NotificacionesCubit>();

    cubit.bindSession(expectedUser);

    final ok = await cubit.markRead(widget.id);

    if (!mounted || _userId != expectedUser || _request != expectedRequest) {
      return;
    }

    if (ok) {
      setState(() {
        _readConfirmed = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.error ??
                'No se pudo marcar como leída. '
                    'Puedes reintentarlo con el botón de lectura.',
          ),
        ),
      );
    }
  }

  void _back() {
    if (!widget.citizen && context.canPop()) {
      context.pop();
    } else {
      context.go(widget.citizen ? '/ciudadano/alertas' : '/notificaciones');
    }
  }

  Future<void> _archive() async {
    final owner = _userId;

    final cubit = context.read<NotificacionesCubit>();
    final ok = await cubit.archive(widget.id);

    if (!mounted || _userId != owner) return;

    if (ok) {
      _back();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.error ?? 'No se pudo archivar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (previous, current) =>
          previous.session?.usuario.idUsuario !=
              current.session?.usuario.idUsuario ||
          previous.isAuthenticated != current.isAuthenticated,
      listener: (_, session) {
        _request++;

        setState(() {
          _item = null;
          _loading = false;
          _readConfirmed = false;
          _error = null;
        });

        if (session.isAuthenticated) {
          _load();
        }
      },
      child: BlocBuilder<NotificacionesCubit, NotificacionesState>(
        builder: (context, state) {
          final item = _item;
          final note = item?.notificacion;

          final session = context.read<SessionBloc>().state;
          final roles = getSessionRoles(session);
          final operational = roles.any(operationalRoles.contains);

          String? target;
          String? targetLabel;

          if (note?.tipoEntidad == 'PROGRAMACION' &&
              operational &&
              !widget.citizen) {
            target = '/home';
            targetLabel = 'Ver mis asignaciones';
          } else if (note?.tipoEntidad == 'RECORRIDO') {
            if (widget.citizen && roles.contains('CIUDADANO')) {
              target = '/ciudadano/inicio';
              targetLabel = 'Consultar mi servicio';
            } else if (operational) {
              target = '/historial';
              targetLabel = 'Consultar mis recorridos';
            }
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Volver a notificaciones',
                onPressed: _back,
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Detalle de notificación'),
              actions: [
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : item == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error ?? 'Notificación no disponible.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _load,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        note!.titulo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text(_readConfirmed ? 'Leída' : 'No leída'),
                          ),
                          if (item.archivada)
                            const Chip(label: Text('Archivada')),
                          Chip(label: Text(note.prioridad)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(notificationDate(item.createdAt)),
                      const Divider(height: 32),
                      SelectableText(
                        note.mensaje,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (note.tipoEntidad != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Referencia: ${note.tipoEntidad}'
                          ' #${note.idEntidad}',
                        ),
                      ],
                      const SizedBox(height: 28),
                      if (!_readConfirmed)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.done),
                          label: const Text('Marcar como leída'),
                          onPressed: state.mutating
                              ? null
                              : () {
                                  final user = _userId;

                                  if (user != null) {
                                    _markRead(
                                      expectedUser: user,
                                      expectedRequest: _request,
                                    );
                                  }
                                },
                        ),
                      if (target != null)
                        FilledButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: Text(targetLabel!),
                          onPressed: () => context.go(target!),
                        ),
                      if (!item.archivada)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.archive_outlined),
                          label: const Text('Archivar notificación'),
                          onPressed: state.mutating ? null : _archive,
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
