import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Content
import 'ciudadano_domicilios_content.dart';

// Pages
import 'ciudadano_domicilio_detalle/ciudadano_domicilio_detalle_page.dart';

class CiudadanoDomiciliosPage extends StatefulWidget {
  const CiudadanoDomiciliosPage({super.key});

  @override
  State<CiudadanoDomiciliosPage> createState() =>
      _CiudadanoDomiciliosPageState();
}

class _CiudadanoDomiciliosPageState extends State<CiudadanoDomiciliosPage> {
  bool _dialogOpen = false;
  bool _formOpen = false;

  // *********************************************************
  // 1. CARGAR LISTADO
  // *********************************************************

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadDomicilios();
    });
  }

  void _loadDomicilios({bool? incluirInactivos}) {
    final bloc = context.read<CiudadanoDomiciliosBloc>();

    if (bloc.state.isBusy) return;

    bloc.add(
      CiudadanoDomiciliosRequested(
        incluirInactivos: incluirInactivos ?? bloc.state.incluirInactivos,
      ),
    );
  }

  // *********************************************************
  // 2. MOSTRAR MENSAJE
  // *********************************************************

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // *********************************************************
  // 3. ABRIR FORMULARIO
  // *********************************************************

  Future<void> _openForm({GetMisDomiciliosDataModel? domicilio}) async {
    if (_formOpen ||
        _dialogOpen ||
        context.read<CiudadanoDomiciliosBloc>().state.isBusy) {
      return;
    }

    _formOpen = true;

    try {
      if (domicilio == null) {
        await context.pushNamed<bool>('ciudadano-domicilio-crear');
      } else {
        await context.pushNamed<bool>(
          'ciudadano-domicilio-editar',
          pathParameters: {'idDomicilio': domicilio.idDomicilio.toString()},
        );
      }
    } finally {
      _formOpen = false;
    }
  }

  // *********************************************************
  // 4. CONFIRMAR ACCIÓN
  // *********************************************************

  Future<void> _confirmAction({
    required GetMisDomiciliosDataModel domicilio,
    required bool eliminar,
  }) async {
    if (_dialogOpen ||
        _formOpen ||
        context.read<CiudadanoDomiciliosBloc>().state.isBusy) {
      return;
    }

    _dialogOpen = true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              eliminar
                  ? 'Eliminar domicilio'
                  : 'Establecer domicilio principal',
            ),
            content: Text(
              eliminar
                  ? '¿Deseas eliminar "${domicilio.nombreDomicilio}"?'
                  : '¿Deseas establecer "${domicilio.nombreDomicilio}" '
                        'como tu domicilio principal?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: eliminar
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(
                          dialogContext,
                        ).colorScheme.error,
                        foregroundColor: Theme.of(
                          dialogContext,
                        ).colorScheme.onError,
                      )
                    : null,
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(eliminar ? 'Eliminar' : 'Establecer principal'),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) return;

      final session = context.read<SessionBloc>().state;
      final bloc = context.read<CiudadanoDomiciliosBloc>();

      if (!session.isAuthenticated || bloc.state.isBusy) return;

      // Verificar que sigue presente en el listado actual.
      final exists = bloc.state.domicilios.any(
        (item) => item.idDomicilio == domicilio.idDomicilio,
      );

      if (!exists) return;

      if (eliminar) {
        bloc.add(
          CiudadanoDomicilioDeleteSubmitted(idDomicilio: domicilio.idDomicilio),
        );
      } else {
        bloc.add(
          CiudadanoDomicilioPrincipalSubmitted(
            idDomicilio: domicilio.idDomicilio,
          ),
        );
      }
    } finally {
      _dialogOpen = false;
    }
  }

  // *********************************************************
  // 5. SINCRONIZAR OTRAS PANTALLAS
  // *********************************************************

  void _refreshRelatedScreens() {
    context.read<CiudadanoInicioBloc>().add(const CiudadanoInicioRequested());

    context.read<CiudadanoCuentaBloc>().add(const CiudadanoCuentaRequested());
  }

  // *********************************************************
  // 6. ABRIR DETALLE A PANTALLA COMPLETA
  // *********************************************************

  Future<void> _openDetalle(GetMisDomiciliosDataModel domicilio) async {
    if (_dialogOpen ||
        _formOpen ||
        context.read<CiudadanoDomiciliosBloc>().state.isBusy) {
      return;
    }

    _dialogOpen = true;

    try {
      await showDialog<void>(
        context: context,
        useSafeArea: false,
        builder: (_) {
          return Dialog.fullscreen(
            child: CiudadanoDomicilioDetallePage(domicilio: domicilio),
          );
        },
      );
    } finally {
      _dialogOpen = false;
    }
  }

  // *********************************************************
  // 7. CONFIRMAR ELIMINACIÓN DEL DOMICILIO
  // *********************************************************

  Future<void> _confirmarEliminar(GetMisDomiciliosDataModel domicilio) async {
    final bloc = context.read<CiudadanoDomiciliosBloc>();

    if (_dialogOpen || _formOpen || bloc.state.isBusy) {
      return;
    }

    _dialogOpen = true;

    try {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final colors = Theme.of(dialogContext).colorScheme;

          return AlertDialog(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colors.error,
              size: 36,
            ),
            title: const Text('Eliminar domicilio'),
            content: Text(
              '¿Deseas eliminar "${domicilio.nombreDomicilio}" '
              'de tus domicilios registrados?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmado != true || bloc.isClosed) {
        return;
      }

      final session = context.read<SessionBloc>().state;

      if (!session.isAuthenticated || bloc.state.isBusy) {
        return;
      }

      final existe = bloc.state.domicilios.any(
        (item) => item.idDomicilio == domicilio.idDomicilio,
      );

      if (!existe) {
        _showMessage(
          'El domicilio ya no está disponible. Actualiza el listado.',
        );
        return;
      }

      bloc.add(
        CiudadanoDomicilioDeleteSubmitted(idDomicilio: domicilio.idDomicilio),
      );
    } finally {
      _dialogOpen = false;
    }
  }

  Future<void> _confirmarEstado(GetMisDomiciliosDataModel domicilio) async {
    final bloc = context.read<CiudadanoDomiciliosBloc>();

    if (_dialogOpen || _formOpen || bloc.state.isBusy) {
      return;
    }

    final activar = domicilio.estadoDomicilio == 'INACTIVO';

    if (!activar && domicilio.esPrincipal) {
      _showMessage(
        'Primero establece otro domicilio como principal '
        'para poder desactivar este.',
      );
      return;
    }

    _dialogOpen = true;

    try {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(activar ? 'Activar domicilio' : 'Desactivar domicilio'),
            content: Text(
              activar
                  ? '¿Deseas volver a utilizar '
                        '"${domicilio.nombreDomicilio}" '
                        'para el servicio de recolección?'
                  : '¿Deseas desactivar '
                        '"${domicilio.nombreDomicilio}"? '
                        'La dirección se conservará y podrás '
                        'activarla nuevamente.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(activar ? 'Activar' : 'Desactivar'),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmado != true || bloc.isClosed) {
        return;
      }

      if (!context.read<SessionBloc>().state.isAuthenticated ||
          bloc.state.isBusy) {
        return;
      }

      // Comprobar el estado actual después de la confirmación.
      GetMisDomiciliosDataModel? actual;

      for (final item in bloc.state.domicilios) {
        if (item.idDomicilio == domicilio.idDomicilio) {
          actual = item;
          break;
        }
      }

      if (actual == null) {
        _showMessage('El domicilio ya no está disponible.');
        return;
      }

      final esperadoActual = activar ? 'INACTIVO' : 'ACTIVO';

      if (actual.estadoDomicilio != esperadoActual) {
        _showMessage('El domicilio cambió de estado. Revisa el listado.');
        return;
      }

      if (!activar && actual.esPrincipal) {
        _showMessage('Primero establece otro domicilio como principal.');
        return;
      }

      bloc.add(
        CiudadanoDomicilioEstadoSubmitted(
          idDomicilio: actual.idDomicilio,
          activo: activar,
        ),
      );
    } finally {
      _dialogOpen = false;
    }
  }

  // *********************************************************
  // 8. INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CiudadanoDomiciliosBloc, CiudadanoDomiciliosState>(
      listener: (context, state) {
        // Los formularios mostrarán sus propios mensajes.
        // El listado permanece montado debajo de ellos.
        if (_formOpen) return;

        if (state.isActionFailure) {
          _showMessage(
            state.actionErrorMessage ?? 'No se pudo completar la operación.',
          );
        } else if (state.isActionSuccess) {
          _showMessage(
            state.successMessage ?? 'Operación realizada correctamente.',
          );
        }
      },
      listenWhen: (previous, current) {
        return previous.actionStatus != current.actionStatus;
      },
      builder: (context, state) {
        return BlocListener<CiudadanoDomiciliosBloc, CiudadanoDomiciliosState>(
          listenWhen: (previous, current) {
            return current.cambiosConfirmados > previous.cambiosConfirmados;
          },
          listener: (context, state) {
            _refreshRelatedScreens();
          },
          child: CiudadanoDomiciliosContent(
            state: state,
            onRefresh: () => _loadDomicilios(),
            onToggleInactivos: (value) {
              _loadDomicilios(incluirInactivos: value);
            },
            onCreate: () => _openForm(),
            onEdit: (domicilio) {
              _openForm(domicilio: domicilio);
            },
            onView: (domicilio) {
              _openDetalle(domicilio);
            },
            onSetPrincipal: (domicilio) {
              _confirmAction(domicilio: domicilio, eliminar: false);
            },
            onDelete: (domicilio) {
              _confirmarEliminar(domicilio);
            },
            onChangeEstado: (domicilio) {
              _confirmarEstado(domicilio);
            },
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/ciudadano/perfil');
              }
            },
          ),
        );
      },
    );
  }
}
