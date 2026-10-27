import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class GeolocatorAccesoWidget extends StatefulWidget {
  final bool solicitarPermisoAlEntrar;

  const GeolocatorAccesoWidget({
    super.key,
    this.solicitarPermisoAlEntrar = true,
  });

  @override
  State<GeolocatorAccesoWidget> createState() => _GeolocatorAccesoWidgetState();
}

class _GeolocatorAccesoWidgetState extends State<GeolocatorAccesoWidget>
    with WidgetsBindingObserver {
  late final GeolocatorBloc _bloc;

  bool _solicitudAutomaticaRealizada = false;
  bool _avisoGpsMostrado = false;
  bool _dialogoGpsAbierto = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _bloc = context.read<GeolocatorBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bloc.isClosed) return;

      _verificarAcceso();

      // También contempla un BLoC que ya tenga resultados.
      _evaluarEstado(_bloc.state);
    });
  }

  void _verificarAcceso() {
    if (_bloc.isClosed) return;

    _bloc.add(const VerificarPermisoGeolocator());

    // Este evento verifica el estado actual y luego lo observa.
    _bloc.add(const ObservarServicioGeolocator());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verificarAcceso();
    }
  }

  void _evaluarEstado(GeolocatorState state) {
    final permisoVerificado = state.permiso is Success<PermisoUbicacion>;

    if (!permisoVerificado) return;

    if (!state.tienePermiso) {
      if (widget.solicitarPermisoAlEntrar && !_solicitudAutomaticaRealizada) {
        // Marcar antes de enviar el evento evita solicitudes repetidas.
        _solicitudAutomaticaRealizada = true;

        _bloc.add(const SolicitarPermisoGeolocator());
      }

      return;
    }

    // Esperar a que termine el permiso evita superponer diálogos.
    if (state.servicioHabilitado == false &&
        !_avisoGpsMostrado &&
        !_dialogoGpsAbierto) {
      _avisoGpsMostrado = true;
      _mostrarDialogoGps();
    }
  }

  Future<void> _mostrarDialogoGps() async {
    if (!mounted || _dialogoGpsAbierto) return;

    _dialogoGpsAbierto = true;

    try {
      final abrirAjustes = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Activa tu ubicación'),
            content: const Text(
              'El servicio de ubicación está apagado. '
              'Actívalo para mostrar tu posición y utilizar '
              'el seguimiento del recorrido.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Ahora no'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Abrir ajustes'),
              ),
            ],
          );
        },
      );

      if (!mounted || _bloc.isClosed) return;

      if (abrirAjustes == true) {
        _bloc.add(const AbrirConfiguracionUbicacionGeolocator());
      }
    } finally {
      _dialogoGpsAbierto = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // El BlocProvider propietario administra el cierre del BLoC.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeolocatorBloc, GeolocatorState>(
      listener: (context, state) {
        _evaluarEstado(state);
      },
      builder: (context, state) {
        if (state.servicioHabilitado == true && state.tienePermiso) {
          return const SizedBox.shrink();
        }

        final verificando =
            state.servicio is Initial<bool> ||
            state.servicio is Loading<bool> ||
            state.permiso is Initial<PermisoUbicacion> ||
            state.permiso is Loading<PermisoUbicacion>;

        final errorVerificacion =
            state.servicio is ErrorData<bool> ||
            state.permiso is ErrorData<PermisoUbicacion>;

        final abriendoAjustes =
            state.aperturaConfiguracionAplicacion is Loading<bool> ||
            state.aperturaConfiguracionUbicacion is Loading<bool>;

        final errorApertura =
            state.aperturaConfiguracionAplicacion is ErrorData<bool> ||
            state.aperturaConfiguracionUbicacion is ErrorData<bool> ||
            (state.aperturaConfiguracionAplicacion is Success<bool> &&
                (state.aperturaConfiguracionAplicacion as Success<bool>).data ==
                    false) ||
            (state.aperturaConfiguracionUbicacion is Success<bool> &&
                (state.aperturaConfiguracionUbicacion as Success<bool>).data ==
                    false);

        final ocupado = verificando || abriendoAjustes;

        return Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acceso a tu ubicación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                if (ocupado) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    abriendoAjustes
                        ? 'Abriendo configuración…'
                        : 'Verificando GPS y permisos…',
                  ),
                ] else ...[
                  Text(
                    state.servicioHabilitado == null
                        ? 'GPS: sin verificar'
                        : state.servicioHabilitado == true
                        ? 'GPS: activado'
                        : 'GPS: desactivado',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.permisoActual == null
                        ? 'Permiso: sin verificar'
                        : state.tienePermiso
                        ? 'Permiso: concedido'
                        : 'Permiso: acceso no autorizado',
                  ),

                  if (errorVerificacion) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'No se pudo comprobar el acceso. '
                      'Intenta verificar nuevamente.',
                    ),
                  ],

                  if (errorApertura) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'No se pudo abrir la configuración. '
                      'Puedes acceder desde los ajustes del celular.',
                    ),
                  ],

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!state.tienePermiso && state.permisoActual != null)
                        FilledButton.icon(
                          onPressed: () {
                            _solicitudAutomaticaRealizada = true;
                            _bloc.add(const SolicitarPermisoGeolocator());
                          },
                          icon: const Icon(Icons.location_on),
                          label: const Text('Permitir ubicación'),
                        ),

                      if (!state.tienePermiso)
                        OutlinedButton(
                          onPressed: () {
                            _bloc.add(
                              const AbrirConfiguracionAplicacionGeolocator(),
                            );
                          },
                          child: const Text('Ajustes de permisos'),
                        ),

                      if (state.servicioHabilitado == false)
                        FilledButton.icon(
                          onPressed: () {
                            _bloc.add(
                              const AbrirConfiguracionUbicacionGeolocator(),
                            );
                          },
                          icon: const Icon(Icons.gps_off),
                          label: const Text('Activar GPS'),
                        ),

                      TextButton(
                        onPressed: _verificarAcceso,
                        child: const Text('Verificar nuevamente'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
