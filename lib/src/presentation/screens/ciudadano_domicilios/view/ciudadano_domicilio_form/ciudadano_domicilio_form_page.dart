import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'ciudadano_domicilio_form_content.dart';

class CiudadanoDomicilioFormPage extends StatefulWidget {
  final int? idDomicilio;

  const CiudadanoDomicilioFormPage({super.key, this.idDomicilio});

  @override
  State<CiudadanoDomicilioFormPage> createState() =>
      _CiudadanoDomicilioFormPageState();
}

class _CiudadanoDomicilioFormPageState
    extends State<CiudadanoDomicilioFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _referencia = TextEditingController();
  final _observacion = TextEditingController();

  late final CiudadanoDomiciliosBloc _bloc;

  double? _latitud;
  double? _longitud;

  int? _idZona;
  int? _idRuta;

  bool _principal = false;
  bool _inicializado = false;
  bool _guardando = false;
  bool _seleccionandoMapa = false;

  int _cambiosAntesDeGuardar = 0;
  String? _errorInicial;

  bool get _editando => widget.idDomicilio != null;

  @override
  void initState() {
    super.initState();

    _bloc = context.read<CiudadanoDomiciliosBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bloc.isClosed) return;

      _bloc.add(const CiudadanoDomicilioCoberturaReset());

      if (!_editando) {
        setState(() => _inicializado = true);
        return;
      }

      final domicilio = _buscarDomicilio(_bloc.state);

      if (domicilio != null) {
        _cargarDomicilio(domicilio);
      } else {
        _cargarListado();
      }
    });
  }

  GetMisDomiciliosDataModel? _buscarDomicilio(CiudadanoDomiciliosState state) {
    for (final item in state.domicilios) {
      if (item.idDomicilio == widget.idDomicilio) {
        return item;
      }
    }

    return null;
  }

  void _cargarListado() {
    if (_bloc.isClosed || _bloc.state.isBusy) return;

    setState(() => _errorInicial = null);

    _bloc.add(const CiudadanoDomiciliosRequested(incluirInactivos: true));
  }

  void _cargarDomicilio(GetMisDomiciliosDataModel domicilio) {
    _nombre.text = domicilio.nombreDomicilio;
    _direccion.text = domicilio.direccion;
    _referencia.text = domicilio.referencia ?? '';
    _observacion.text = domicilio.observacion ?? '';

    setState(() {
      _latitud = domicilio.latitud;
      _longitud = domicilio.longitud;
      _idZona = domicilio.idZona;
      _idRuta = domicilio.idRuta;
      _principal = domicilio.esPrincipal;
      _inicializado = true;
      _errorInicial = null;
    });

    _resolverCobertura();
  }

  // =========================================================
  // COBERTURA
  // =========================================================

  bool _coberturaCorresponde(CiudadanoDomiciliosState state) {
    final data = state.cobertura;
    final lat = _latitud;
    final lng = _longitud;

    if (!state.isCoberturaReady || data == null || lat == null || lng == null) {
      return false;
    }

    const tolerance = 0.0000001;

    return (data.latitud - lat).abs() <= tolerance &&
        (data.longitud - lng).abs() <= tolerance;
  }

  CoberturaZonaModel? _zonaSeleccionada(CiudadanoDomiciliosState state) {
    if (!_coberturaCorresponde(state)) return null;

    for (final zona in state.cobertura!.zonas) {
      if (zona.idZona == _idZona) return zona;
    }

    return null;
  }

  bool _puedeGuardar(CiudadanoDomiciliosState state) {
    if (!_inicializado ||
        _guardando ||
        _seleccionandoMapa ||
        state.isBusy ||
        state.isResolviendoCobertura ||
        !_coberturaCorresponde(state) ||
        !state.tieneCobertura) {
      return false;
    }

    final zona = _zonaSeleccionada(state);

    return zona != null && zona.rutas.any((ruta) => ruta.idRuta == _idRuta);
  }

  void _resolverCobertura() {
    final lat = _latitud;
    final lng = _longitud;

    if (lat == null || lng == null || _bloc.isClosed) return;

    // Se conservan los IDs actuales únicamente para intentar
    // recuperarlos si siguen presentes en la nueva respuesta.
    _bloc.add(
      CiudadanoDomicilioCoberturaRequested(
        request: ResolverCoberturaRequest(latitud: lat, longitud: lng),
      ),
    );
  }

  void _aplicarCobertura(CiudadanoDomiciliosState state) {
    if (!_coberturaCorresponde(state)) return;

    final data = state.cobertura!;

    CoberturaZonaModel? zona;

    // Al editar, mantener la selección anterior si sigue vigente.
    for (final candidate in data.zonas) {
      if (candidate.idZona == _idZona) {
        zona = candidate;
        break;
      }
    }

    if (zona == null && data.idZonaSugerida != null) {
      for (final candidate in data.zonas) {
        if (candidate.idZona == data.idZonaSugerida) {
          zona = candidate;
          break;
        }
      }
    }

    if (zona == null && data.zonas.length == 1) {
      zona = data.zonas.single;
    }

    final rutas = zona?.rutas ?? const <CoberturaRutaModel>[];

    final rutaAnteriorValida = rutas.any((ruta) => ruta.idRuta == _idRuta);

    setState(() {
      _idZona = zona?.idZona;
      _idRuta = rutaAnteriorValida
          ? _idRuta
          : rutas.length == 1
          ? rutas.single.idRuta
          : null;
    });
  }

  void _seleccionarZona(int? idZona) {
    final data = _bloc.state.cobertura;

    if (data == null) return;

    CoberturaZonaModel? seleccionada;

    for (final zona in data.zonas) {
      if (zona.idZona == idZona) {
        seleccionada = zona;
        break;
      }
    }

    setState(() {
      _idZona = seleccionada?.idZona;
      _idRuta = seleccionada?.rutas.length == 1
          ? seleccionada!.rutas.single.idRuta
          : null;
    });
  }

  // =========================================================
  // SELECCIONAR UBICACIÓN
  // =========================================================

  Future<void> _seleccionarUbicacion() async {
    if (_guardando || _seleccionandoMapa || _bloc.state.isBusy) {
      return;
    }

    setState(() => _seleccionandoMapa = true);

    // Centro inicial de referencia en Calca.
    final initialLat = _latitud ?? -13.3214;
    final initialLng = _longitud ?? -71.9556;

    try {
      mb.MapboxMap? mapa;
      bool confirmando = false;
      String? errorMapa;

      final punto = await showDialog<(double, double)>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return PopScope(
                canPop: !confirmando,
                child: Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 600,
                    height: MediaQuery.sizeOf(dialogContext).height * 0.8,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Mueve el mapa hasta colocar tu domicilio '
                            'debajo del marcador.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AbsorbPointer(
                                absorbing: confirmando,
                                child: mb.MapWidget(
                                  styleUri: mb.MapboxStyles.MAPBOX_STREETS,
                                  viewport: mb.CameraViewportState(
                                    center: mb.Point(
                                      coordinates: mb.Position(
                                        initialLng,
                                        initialLat,
                                      ),
                                    ),
                                    zoom: 16,
                                  ),
                                  onMapCreated: (value) {
                                    if (!dialogContext.mounted) return;

                                    setDialogState(() => mapa = value);
                                  },
                                ),
                              ),
                              IgnorePointer(
                                child: Center(
                                  // La punta del icono queda en el centro.
                                  child: Transform.translate(
                                    offset: Offset(0, -22),
                                    child: Icon(
                                      Icons.location_pin,
                                      size: 44,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (errorMapa != null)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(errorMapa!),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: confirmando
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: mapa == null || confirmando
                                    ? null
                                    : () async {
                                        setDialogState(() {
                                          confirmando = true;
                                          errorMapa = null;
                                        });

                                        try {
                                          final camera = await mapa!
                                              .getCameraState();

                                          if (!dialogContext.mounted) return;

                                          final coordinates =
                                              camera.center.coordinates;

                                          Navigator.of(dialogContext).pop((
                                            coordinates.lat.toDouble(),
                                            coordinates.lng.toDouble(),
                                          ));
                                        } catch (_) {
                                          if (!dialogContext.mounted) return;

                                          setDialogState(() {
                                            confirmando = false;
                                            errorMapa =
                                                'No se pudo obtener el punto. '
                                                'Intenta nuevamente.';
                                          });
                                        }
                                      },
                                child: Text(
                                  confirmando
                                      ? 'Confirmando…'
                                      : 'Confirmar ubicación',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (!mounted || punto == null) return;

      _bloc.add(const CiudadanoDomicilioCoberturaReset());

      setState(() {
        _latitud = punto.$1;
        _longitud = punto.$2;
        _idZona = null;
        _idRuta = null;
      });

      _resolverCobertura();
    } finally {
      if (mounted) {
        setState(() => _seleccionandoMapa = false);
      }
    }
  }

  // =========================================================
  // GUARDAR
  // =========================================================

  void _guardar() {
    if (!_puedeGuardar(_bloc.state)) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!context.read<SessionBloc>().state.isAuthenticated) {
      _mensaje('Debes iniciar sesión para guardar el domicilio.');
      return;
    }

    setState(() {
      _guardando = true;
      _cambiosAntesDeGuardar = _bloc.state.cambiosConfirmados;
    });

    if (_editando) {
      _bloc.add(
        CiudadanoDomicilioUpdateSubmitted(
          idDomicilio: widget.idDomicilio!,
          request: UpdateCiudadanoDomicilioRequest(
            idZona: _idZona!,
            idRuta: _idRuta!,
            nombreDomicilio: _nombre.text.trim(),
            direccion: _direccion.text.trim(),
            referencia: _referencia.text.trim(),
            latitud: _latitud!,
            longitud: _longitud!,
            origenUbicacion: 'MAPA',
            observacion: _observacion.text.trim(),
          ),
        ),
      );
    } else {
      _bloc.add(
        CiudadanoDomicilioCreateSubmitted(
          request: CreateCiudadanoDomicilioRequest(
            idZona: _idZona!,
            idRuta: _idRuta!,
            nombreDomicilio: _nombre.text.trim(),
            direccion: _direccion.text.trim(),
            referencia: _referencia.text.trim(),
            latitud: _latitud!,
            longitud: _longitud!,
            origenUbicacion: 'MAPA',
            esPrincipal: _principal,
            observacion: _observacion.text.trim(),
          ),
        ),
      );
    }
  }

  void _onEstado(BuildContext context, CiudadanoDomiciliosState state) {
    if (!_inicializado && _editando) {
      if (state.status == CiudadanoDomiciliosStatus.ready) {
        final domicilio = _buscarDomicilio(state);

        if (domicilio != null) {
          _cargarDomicilio(domicilio);
        } else {
          setState(() {
            _errorInicial =
                'El domicilio no existe o no está disponible para tu usuario.';
          });
        }
      } else if (state.status == CiudadanoDomiciliosStatus.failure) {
        setState(() => _errorInicial = state.errorMessage);
      }
    }

    if (state.isCoberturaReady) {
      _aplicarCobertura(state);
    }

    if (!_guardando) return;

    final expectedAction = _editando
        ? CiudadanoDomiciliosAction.update
        : CiudadanoDomiciliosAction.create;

    if (state.action != expectedAction) return;

    if (state.isActionFailure) {
      setState(() => _guardando = false);

      _mensaje(state.actionErrorMessage ?? 'No se pudo guardar el domicilio.');
    } else if (state.isActionSuccess &&
        state.cambiosConfirmados > _cambiosAntesDeGuardar) {
      // También se cumple si se guardó pero falló la recarga.
      final message = state.status == CiudadanoDomiciliosStatus.failure
          ? state.errorMessage
          : state.successMessage;

      _mensaje(message ?? 'Domicilio guardado correctamente.');
      _salir(guardado: true);
    }
  }

  void _mensaje(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _salir({bool guardado = false}) {
    if (context.canPop()) {
      context.pop(guardado);
    } else {
      context.goNamed('ciudadano-domicilios');
    }
  }

  @override
  void dispose() {
    if (!_bloc.isClosed) {
      _bloc.add(const CiudadanoDomicilioCoberturaReset());
    }

    _nombre.dispose();
    _direccion.dispose();
    _referencia.dispose();
    _observacion.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CiudadanoDomiciliosBloc, CiudadanoDomiciliosState>(
      listener: _onEstado,
      builder: (context, state) {
        return CiudadanoDomicilioFormContent(
          formKey: _formKey,
          editando: _editando,
          inicializado: _inicializado,
          guardando: _guardando,
          bloqueado: _guardando || state.isBusy || _seleccionandoMapa,
          errorInicial: _errorInicial,
          nombre: _nombre,
          direccion: _direccion,
          referencia: _referencia,
          observacion: _observacion,
          latitud: _latitud,
          longitud: _longitud,
          principal: _principal,
          idZona: _idZona,
          idRuta: _idRuta,
          cobertura: _coberturaCorresponde(state) ? state.cobertura : null,
          cargandoCobertura: state.isResolviendoCobertura,
          errorCobertura: state.coberturaErrorMessage,
          puedeGuardar: _puedeGuardar(state),
          onPrincipal: (value) => setState(() => _principal = value),
          onZona: _seleccionarZona,
          onRuta: (value) => setState(() => _idRuta = value),
          onUbicacion: _seleccionarUbicacion,
          onConsultarCobertura: _resolverCobertura,
          onGuardar: _guardar,
          onReintentar: _cargarListado,
          onBack: () => _salir(),
        );
      },
    );
  }
}
