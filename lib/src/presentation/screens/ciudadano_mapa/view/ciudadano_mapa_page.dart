import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Controllers
import 'controllers/ciudadano_mapa_dibujo_controller.dart';

// Content
import 'ciudadano_mapa_content.dart';

class CiudadanoMapaPage extends StatefulWidget {
  const CiudadanoMapaPage({super.key});

  @override
  State<CiudadanoMapaPage> createState() => _CiudadanoMapaPageState();
}

class _CiudadanoMapaPageState extends State<CiudadanoMapaPage> {
  late final CiudadanoMapaBloc _bloc;
  late final CiudadanoMapaDibujoController _dibujo;
  late final Widget _mapaBase;

  @override
  void initState() {
    super.initState();

    _bloc = context.read<CiudadanoMapaBloc>();

    _dibujo = CiudadanoMapaDibujoController(onError: _mensaje);

    _mapaBase = MapaBaseConBloc(
      onMapCreated: _dibujo.asociarMapa,
      onStyleLoaded: () {
        unawaited(_dibujo.prepararAnotaciones());
      },
    );

    // Recupera datos si la pantalla se reconstruye con una
    // consulta que ya estaba en curso o había terminado.
    _dibujo.actualizar(_bloc.state.datos);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bloc.isClosed) return;

      _bloc.add(const CiudadanoMapaRequested());
    });
  }

  void _actualizar() {
    if (_bloc.isClosed || _bloc.state.isBusy) return;

    final state = _bloc.state;

    if (state.errorEnDomicilios || state.idDomicilioSeleccionado == null) {
      _bloc.add(const CiudadanoMapaRequested());
    } else {
      _bloc.add(const CiudadanoMapaServicioRequested());
    }
  }

  void _onEstado(BuildContext context, CiudadanoMapaState state) {
    _dibujo.actualizar(state.datos);

    final domicilio = state.datos?.domicilio;

    if (domicilio != null) {
      unawaited(_dibujo.centrar(domicilio.latitud, domicilio.longitud));
    }
  }

  void _mensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _dibujo.dispose();

    // El BlocProvider es responsable de cerrar el BLoC.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CiudadanoMapaBloc, CiudadanoMapaState>(
      listenWhen: (anterior, actual) => anterior.datos != actual.datos,
      listener: _onEstado,
      builder: (context, state) {
        final domicilio = state.datos?.domicilio;
        final camion = state.datos?.servicio?.ultimaUbicacion;

        return CiudadanoMapaContent(
          mapaBase: _mapaBase,

          domicilios: state.domicilios,
          idDomicilio: state.idDomicilioSeleccionado,
          datos: state.datos,

          cargando: state.isInitial || state.isBusy,
          error: state.errorMessage,

          onSeleccionarDomicilio: (id) {
            _bloc.add(CiudadanoMapaDomicilioSelected(idDomicilio: id));
          },

          onActualizar: _actualizar,

          onAbrirCuenta: () {
            context.go('/ciudadano/perfil');
          },

          onNotificaciones: () {
            context.push('/ciudadano/alertas');
          },

          onCentrarDomicilio: domicilio == null
              ? null
              : () {
                  unawaited(
                    _dibujo.centrar(domicilio.latitud, domicilio.longitud),
                  );
                },

          onCentrarCamion: camion == null
              ? null
              : () {
                  unawaited(_dibujo.centrar(camion.latitud, camion.longitud));
                },
        );
      },
    );
  }
}
