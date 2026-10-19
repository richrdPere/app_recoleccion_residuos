import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Models
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:go_router/go_router.dart';

// Content
import 'recorrido_content.dart';

class RecorridoPage extends StatefulWidget {
  const RecorridoPage({super.key});

  @override
  State<RecorridoPage> createState() => _RecorridoPageState();
}

class _RecorridoPageState extends State<RecorridoPage> {
  bool _preparandoAccion = false;

  bool get _puedeGestionar {
    final sessionState = context.read<SessionBloc>().state;

    return sessionState.isAuthenticated &&
        sessionState.session?.usuario.esConductor == true;
  }

  // *********************************************************
  // 1. CONSULTAR RECORRIDO ACTIVO
  // *********************************************************
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<RecorridoBloc>();

      if (bloc.isClosed ||
          bloc.state.isLoadingActivo ||
          bloc.state.isProcessingAccion) {
        return;
      }

      bloc.add(const ObtenerRecorridoActivo());
    });
  }

  // *********************************************************
  // 2. ACTUALIZAR RECORRIDO
  // *********************************************************
  Future<void> _refresh() async {
    final bloc = context.read<RecorridoBloc>();

    if (bloc.isClosed || _preparandoAccion || bloc.state.isProcessingAccion) {
      return;
    }

    // Suscribirse antes del evento.
    final completion = bloc.stream.firstWhere(
      (state) =>
          state.activoResponse is Success<ApiResponse<RecorridoDataModel?>> ||
          state.activoResponse is ErrorData<ApiResponse<RecorridoDataModel?>>,
    );

    if (!bloc.state.isLoadingActivo) {
      bloc.add(const ObtenerRecorridoActivo());
    }

    try {
      await completion;
    } on StateError {
      // La aplicación pudo cerrar el Bloc durante la consulta.
    }
  }

  // *********************************************************
  // 3. MOSTRAR MENSAJES
  // *********************************************************
  void _mostrarMensaje(String message, {bool error = false}) {
    if (!mounted || message.trim().isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  // *********************************************************
  // 4. CONFIRMAR ACCIÓN
  // *********************************************************
  Future<String?> _confirmarAccion(RecorridoAccion accion) async {
    final controller = TextEditingController();

    final titulo = switch (accion) {
      RecorridoAccion.pausar => 'Pausar recorrido',
      RecorridoAccion.reanudar => 'Reanudar recorrido',
      RecorridoAccion.finalizar => 'Finalizar recorrido',
      RecorridoAccion.iniciar => 'Iniciar recorrido',
    };

    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(titulo),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accion == RecorridoAccion.finalizar
                        ? '¿Terminaste la operación? Se consultará '
                              'tu ubicación actual para finalizar.'
                        : '¿Deseas continuar con esta acción?',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Observación opcional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  // *********************************************************
  // 5. EJECUTAR ACCIÓN
  // *********************************************************
  Future<void> _ejecutarAccion(RecorridoAccion accion) async {
    final bloc = context.read<RecorridoBloc>();
    final state = bloc.state;
    final recorrido = state.recorridoActivo;

    if (!_puedeGestionar ||
        recorrido == null ||
        bloc.isClosed ||
        _preparandoAccion ||
        state.isProcessingAccion ||
        state.isLoadingActivo) {
      return;
    }

    final estado = recorrido.estadoRecorrido.toUpperCase();

    final permitida = switch (accion) {
      RecorridoAccion.pausar => estado == 'EN_CURSO',
      RecorridoAccion.reanudar => estado == 'PAUSADO',
      RecorridoAccion.finalizar => estado == 'EN_CURSO' || estado == 'PAUSADO',
      RecorridoAccion.iniciar => false,
    };

    if (!permitida) return;

    setState(() => _preparandoAccion = true);

    try {
      final observacion = await _confirmarAccion(accion);

      if (!mounted || observacion == null || bloc.isClosed) return;

      var actual = bloc.state.recorridoActivo;

      if (actual?.idRecorrido != recorrido.idRecorrido ||
          actual?.estadoRecorrido != recorrido.estadoRecorrido) {
        _mostrarMensaje(
          'El recorrido cambió. Actualiza antes de continuar.',
          error: true,
        );
        return;
      }

      final texto = observacion.isEmpty ? null : observacion;

      switch (accion) {
        case RecorridoAccion.pausar:
          bloc.add(
            PausarRecorrido(
              idRecorrido: recorrido.idRecorrido,
              request: PausarRecorridoRequest(
                observacion: texto,
                fechaEvento: DateTime.now(),
              ),
            ),
          );
          break;

        case RecorridoAccion.reanudar:
          bloc.add(
            ReanudarRecorrido(
              idRecorrido: recorrido.idRecorrido,
              request: ReanudarRecorridoRequest(
                observacion: texto,
                fechaEvento: DateTime.now(),
              ),
            ),
          );
          break;

        case RecorridoAccion.finalizar:
          // final request = await prepararFinalizacion(observacion);

          // if (!mounted || request == null || bloc.isClosed) return;

          // if (!request.latitud.isFinite ||
          //     !request.longitud.isFinite ||
          //     request.latitud < -90 ||
          //     request.latitud > 90 ||
          //     request.longitud < -180 ||
          //     request.longitud > 180) {
          //   _mostrarMensaje('No se obtuvo una ubicación válida.', error: true);
          //   return;
          // }

          // actual = bloc.state.recorridoActivo;

          // if (actual?.idRecorrido != recorrido.idRecorrido ||
          //     actual?.estadoRecorrido != recorrido.estadoRecorrido) {
          //   _mostrarMensaje(
          //     'El recorrido cambió. Actualiza antes de continuar.',
          //     error: true,
          //   );
          //   return;
          // }

          // bloc.add(
          //   FinalizarRecorrido(
          //     idRecorrido: recorrido.idRecorrido,
          //     request: request,
          //   ),
          // );
          break;

        case RecorridoAccion.iniciar:
          break;
      }
    } catch (_) {
      _mostrarMensaje(
        'No se pudo preparar la acción. '
        'Si estás finalizando, verifica el GPS y sus permisos.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _preparandoAccion = false);
      }
    }
  }

  // *********************************************************
  // 6. INTERFAZ Y LISTENER
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionBloc>().state;

    final puedeGestionar =
        sessionState.isAuthenticated &&
        sessionState.session?.usuario.esConductor == true;

    return BlocConsumer<RecorridoBloc, RecorridoState>(
      listenWhen: (previous, current) {
        return !identical(previous.accionResponse, current.accionResponse) ||
            !identical(previous.activoResponse, current.activoResponse);
      },
      listener: (context, state) {
        final accionResponse = state.accionResponse;
        final activoResponse = state.activoResponse;

        // Evita repetir el mensaje de una acción cuando cambia
        // únicamente la consulta del activo.
        final previousAction = _ultimaAccionResponse;
        _ultimaAccionResponse = accionResponse;

        if (!identical(previousAction, accionResponse)) {
          if (accionResponse is Success<ApiResponse<RecorridoDataModel>>) {
            _mostrarMensaje(accionResponse.data.message);
          } else if (accionResponse
              is ErrorData<ApiResponse<RecorridoDataModel>>) {
            _mostrarMensaje(accionResponse.message, error: true);
          }
        }

        final previousActive = _ultimoActivoResponse;
        _ultimoActivoResponse = activoResponse;

        if (!identical(previousActive, activoResponse) &&
            activoResponse is ErrorData<ApiResponse<RecorridoDataModel?>> &&
            state.recorridoActivo != null) {
          _mostrarMensaje(activoResponse.message, error: true);
        }
      },
      builder: (context, state) {
        return RecorridoContent(
          state: state,
          puedeGestionar: puedeGestionar,
          preparandoAccion: _preparandoAccion,
          onRefresh: _refresh,
          onPausar: () => _ejecutarAccion(RecorridoAccion.pausar),
          onReanudar: () => _ejecutarAccion(RecorridoAccion.reanudar),
          onFinalizar: () => _ejecutarAccion(RecorridoAccion.finalizar),
          onIrAInicio: () => context.go('/home'),
        );
      },
    );
  }

  Resource<ApiResponse<RecorridoDataModel>>? _ultimaAccionResponse;
  Resource<ApiResponse<RecorridoDataModel?>>? _ultimoActivoResponse;
}
