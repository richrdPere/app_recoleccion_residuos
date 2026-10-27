import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Content
import 'home_content.dart';

class HomePage extends StatefulWidget {
  final String nombreConductor;
  final VoidCallback? onVerProgramaciones;

  const HomePage({
    super.key,
    this.nombreConductor = 'Conductor',
    this.onVerProgramaciones,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _fechaConsulta;

  int? _idAsignacionSolicitada;
  bool _confirmacionAbierta = false;

  @override
  void initState() {
    super.initState();

    _fechaConsulta = DateUtils.dateOnly(DateTime.now());
    _consultarAsignaciones();
  }

  // *********************************************************
  // CONSULTAR ASIGNACIONES
  // *********************************************************
  void _seleccionarParaRecorrido(MiAsignacionModel asignacion) {
    context.read<ProgramacionesBloc>().add(
      ObtenerProgramacionDetalle(idProgramacion: asignacion.idProgramacion),
    );
  }

  void _consultarAsignaciones() {
    final fecha = _fechaApi(_fechaConsulta);

    context.read<ProgramacionesBloc>().add(
      ObtenerMisAsignaciones(
        filters: MisAsignacionesFilters(
          page: 1,
          limit: 10,
          fechaDesde: fecha,
          fechaHasta: fecha,
        ),
      ),
    );
  }

  void _actualizar() {
    final bloc = context.read<ProgramacionesBloc>();

    if (bloc.state.respondiendoAsignacion || _idAsignacionSolicitada != null) {
      return;
    }

    setState(() {
      _fechaConsulta = DateUtils.dateOnly(DateTime.now());
    });

    _consultarAsignaciones();
  }

  String _fechaApi(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }

  // *********************************************************
  // REGLA VISUAL PARA RESPONDER
  // El backend mantiene la validación definitiva.
  // *********************************************************

  bool _puedeAceptar(MiAsignacionModel asignacion) {
    final estadoAsignacion = asignacion.estadoAsignacion.trim().toUpperCase();

    final estadoProgramacion = asignacion.programacion.estadoProgramacion
        .trim()
        .toUpperCase();

    final pendiente = const {
      'PENDIENTE',
      'ASIGNADO',
    }.contains(estadoAsignacion);

    final programacionDisponible = const {
      'PROGRAMADA',
      'ASIGNADA',
      'ACEPTADA',
    }.contains(estadoProgramacion);

    return pendiente &&
        programacionDisponible &&
        asignacion.idProgramacionPersonal > 0;
  }

  // *********************************************************
  // CONFIRMAR Y ENVIAR ACEPTACIÓN
  // *********************************************************

  Future<void> _aceptarAsignacion(MiAsignacionModel asignacion) async {
    final bloc = context.read<ProgramacionesBloc>();

    if (_confirmacionAbierta ||
        _idAsignacionSolicitada != null ||
        bloc.state.respondiendoAsignacion ||
        !_puedeAceptar(asignacion)) {
      return;
    }

    _confirmacionAbierta = true;

    bool? confirmado;

    try {
      confirmado = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Aceptar programación'),
            content: Text(
              '¿Confirmas que aceptarás tu asignación '
              'para la programación '
              '#${asignacion.idProgramacion}?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                icon: const Icon(Icons.check),
                label: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } finally {
      _confirmacionAbierta = false;
    }

    if (!mounted || confirmado != true) return;

    // La lista pudo cambiar mientras estaba abierto el diálogo.
    final actuales = bloc.state.asignaciones?.data?.items;

    MiAsignacionModel? vigente;

    if (actuales != null) {
      for (final item in actuales) {
        if (item.idProgramacionPersonal == asignacion.idProgramacionPersonal) {
          vigente = item;
          break;
        }
      }
    }

    if (bloc.state.cargandoAsignaciones ||
        bloc.state.respondiendoAsignacion ||
        _idAsignacionSolicitada != null ||
        vigente == null ||
        !_puedeAceptar(vigente)) {
      _mostrarMensaje('La asignación cambió. Actualiza y vuelve a revisarla.');
      return;
    }

    setState(() {
      _idAsignacionSolicitada = asignacion.idProgramacionPersonal;
    });

    bloc.add(
      ResponderAsignacion(
        idProgramacionPersonal: asignacion.idProgramacionPersonal,
        request: const ResponderAsignacionRequest(
          estadoAsignacion: RespuestaAsignacion.aceptado,
        ),
      ),
    );
  }

  // *********************************************************
  // RESULTADO DE LA ACEPTACIÓN
  // *********************************************************

  void _escucharRespuesta(BuildContext context, ProgramacionesState state) {
    final idSolicitado = _idAsignacionSolicitada;

    // Ignorar respuestas iniciadas desde otras pantallas.
    if (idSolicitado == null ||
        state.idProgramacionPersonalRespuesta != idSolicitado ||
        state.respondiendoAsignacion) {
      return;
    }

    final respuesta = state.respuesta;
    final error = state.errorRespuesta;

    if (respuesta == null && error == null) return;

    setState(() {
      _idAsignacionSolicitada = null;
    });

    if (respuesta != null && respuesta.success) {
      final asignacionRespondida = respuesta.data;

      if (asignacionRespondida != null &&
          asignacionRespondida.estadoAsignacion == 'ACEPTADO' &&
          asignacionRespondida.funcion == 'CONDUCTOR' &&
          asignacionRespondida.esPrincipal) {
        context.read<ProgramacionesBloc>().add(
          ObtenerProgramacionDetalle(
            idProgramacion: asignacionRespondida.idProgramacion,
          ),
        );
      }

      _mostrarMensaje(
        respuesta.message.trim().isNotEmpty
            ? respuesta.message
            : 'Asignación aceptada correctamente.',
      );

      _consultarAsignaciones();
      return;
    }

    _mostrarMensaje(
      error ??
          (respuesta != null && respuesta.message.trim().isNotEmpty
              ? respuesta.message
              : 'No se pudo aceptar la asignación.'),
    );
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // *********************************************************
  // UI
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProgramacionesBloc, ProgramacionesState>(
      listenWhen: (anterior, actual) =>
          anterior.respuestaAsignacion != actual.respuestaAsignacion,
      listener: _escucharRespuesta,
      buildWhen: (anterior, actual) =>
          anterior.misAsignaciones != actual.misAsignaciones ||
          anterior.respuestaAsignacion != actual.respuestaAsignacion ||
          anterior.idProgramacionPersonalRespuesta !=
              actual.idProgramacionPersonalRespuesta,
      builder: (context, state) {
        final response = state.asignaciones;

        MisAsignacionesDataModel? datos;
        String? error = state.errorAsignaciones;

        if (response != null) {
          if (!response.success) {
            error = response.message.trim().isEmpty
                ? 'No se pudieron consultar tus asignaciones.'
                : response.message;
          } else if (response.data == null) {
            error = 'La respuesta no contiene las asignaciones.';
          } else {
            datos = response.data;
          }
        }

        final cargando =
            state.cargandoAsignaciones || (response == null && error == null);

        return HomeContent(
          nombreConductor: widget.nombreConductor,
          fecha: _fechaConsulta,
          cargando: cargando,
          datos: datos,
          error: error,
          onActualizar: _actualizar,
          onVerProgramaciones: widget.onVerProgramaciones,

          bloqueandoRespuestas:
              state.respondiendoAsignacion || _idAsignacionSolicitada != null,

          idAsignacionRespondiendo:
              _idAsignacionSolicitada ??
              (state.respondiendoAsignacion
                  ? state.idProgramacionPersonalRespuesta
                  : null),
          onSeleccionarRecorrido: _seleccionarParaRecorrido,
          puedeAceptarAsignacion: _puedeAceptar,

          onAceptarAsignacion: (asignacion) {
            _aceptarAsignacion(asignacion);
          },
        );
      },
    );
  }
}
