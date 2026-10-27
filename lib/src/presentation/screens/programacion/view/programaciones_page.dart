import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Resources
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Content
import 'programaciones_content.dart';

class ProgramacionesPage extends StatefulWidget {
  final MisAsignacionesFilters filtrosIniciales;

  const ProgramacionesPage({
    super.key,
    this.filtrosIniciales = const MisAsignacionesFilters(),
  });

  @override
  State<ProgramacionesPage> createState() => _ProgramacionesPageState();
}

class _ProgramacionesPageState extends State<ProgramacionesPage> {
  late int _pagina;
  late int _limite;

  String? _fechaDesde;
  String? _fechaHasta;

  // Se conservan si la página recibe estos filtros.
  String? _estadoAsignacion;
  String? _estadoProgramacion;

  bool _dialogoRespuestaAbierto = false;

  // *********************************************************
  // INICIALIZACIÓN
  // *********************************************************

  @override
  void initState() {
    super.initState();

    final filtros = widget.filtrosIniciales;

    _pagina = (filtros.page ?? 1) > 0 ? (filtros.page ?? 1) : 1;

    _limite = (filtros.limit ?? 10) > 0 ? (filtros.limit ?? 10) : 10;

    _fechaDesde = filtros.fechaDesde;
    _fechaHasta = filtros.fechaHasta;
    _estadoAsignacion = filtros.estadoAsignacion;
    _estadoProgramacion = filtros.estadoProgramacion;

    _cargarAsignaciones();
  }

  MisAsignacionesFilters get _filtros {
    return MisAsignacionesFilters(
      page: _pagina,
      limit: _limite,
      fechaDesde: _fechaDesde,
      fechaHasta: _fechaHasta,
      estadoAsignacion: _estadoAsignacion,
      estadoProgramacion: _estadoProgramacion,
    );
  }

  // *********************************************************
  // CONSULTAS Y PAGINACIÓN
  // *********************************************************

  void _cargarAsignaciones() {
    context.read<ProgramacionesBloc>().add(
      ObtenerMisAsignaciones(filters: _filtros),
    );
  }

  void _cambiarPagina(int pagina) {
    if (pagina < 1) return;

    final state = context.read<ProgramacionesBloc>().state;

    if (state.cargandoAsignaciones || state.respondiendoAsignacion) {
      return;
    }

    setState(() {
      _pagina = pagina;
    });

    _cargarAsignaciones();
  }

  // *********************************************************
  // FILTROS POR FECHA
  // *********************************************************

  Future<void> _seleccionarFechas() async {
    final hoy = DateUtils.dateOnly(DateTime.now());

    final desde = DateTime.tryParse(_fechaDesde ?? '');
    final hasta = DateTime.tryParse(_fechaHasta ?? '');

    final inicio = desde == null ? hoy : DateUtils.dateOnly(desde);

    final fin = hasta == null ? inicio : DateUtils.dateOnly(hasta);

    final rangoInicial = DateTimeRange(
      start: inicio,
      end: fin.isBefore(inicio) ? inicio : fin,
    );

    final firstDate = rangoInicial.start.isBefore(DateTime(2020))
        ? rangoInicial.start
        : DateTime(2020);

    final ultimoDia = DateTime(hoy.year + 5, 12, 31);

    final lastDate = rangoInicial.end.isAfter(ultimoDia)
        ? rangoInicial.end
        : ultimoDia;

    final seleccion = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: rangoInicial,
      helpText: 'Filtrar programaciones',
      saveText: 'Aplicar',
    );

    if (!mounted || seleccion == null) return;

    setState(() {
      _fechaDesde = _fechaApi(seleccion.start);
      _fechaHasta = _fechaApi(seleccion.end);
      _pagina = 1;
    });

    _cargarAsignaciones();
  }

  void _mostrarHoy() {
    final fecha = _fechaApi(DateTime.now());

    setState(() {
      _fechaDesde = fecha;
      _fechaHasta = fecha;
      _pagina = 1;
    });

    _cargarAsignaciones();
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaDesde = null;
      _fechaHasta = null;
      _estadoAsignacion = null;
      _estadoProgramacion = null;
      _pagina = 1;
    });

    _cargarAsignaciones();
  }

  String _fechaApi(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }

  // *********************************************************
  // RESPONDER ASIGNACIÓN
  // *********************************************************

  Future<void> _responderAsignacion(
    MiAsignacionModel asignacion,
    RespuestaAsignacion respuesta,
  ) async {
    final bloc = context.read<ProgramacionesBloc>();

    if (_dialogoRespuestaAbierto || bloc.state.respondiendoAsignacion) {
      return;
    }

    _dialogoRespuestaAbierto = true;

    final observacionController = TextEditingController();

    try {
      final request = await showDialog<ResponderAsignacionRequest>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(_etiqueta(respuesta.value)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Programación '
                    '#${asignacion.idProgramacion}',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: observacionController,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Observación',
                      hintText: 'Opcional',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(
                    ResponderAsignacionRequest(
                      estadoAsignacion: respuesta,
                      observacion: observacionController.text.trim(),
                    ),
                  );
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );

      if (!mounted || request == null || bloc.isClosed) {
        return;
      }

      if (bloc.state.respondiendoAsignacion) return;

      bloc.add(
        ResponderAsignacion(
          idProgramacionPersonal: asignacion.idProgramacionPersonal,
          request: request,
        ),
      );
    } finally {
      // El diálogo puede seguir ejecutando su animación de salida.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        observacionController.dispose();
      });

      _dialogoRespuestaAbierto = false;
    }
  }

  // *********************************************************
  // RESULTADO DE RESPONDER
  // *********************************************************

  void _onRespuesta(BuildContext context, ProgramacionesState state) {
    final recurso = state.respuestaAsignacion;

    if (recurso is ErrorData<ApiResponse<ResponderAsignacionDataModel>>) {
      _mensaje(recurso.fullMessage);
      return;
    }

    if (recurso is! Success<ApiResponse<ResponderAsignacionDataModel>>) {
      return;
    }

    final response = recurso.data;

    if (!response.success) {
      _mensaje(
        response.error?.trim().isNotEmpty == true
            ? '${response.message} ${response.error}'
            : response.message,
      );
      return;
    }

    _mensaje(
      response.message.trim().isEmpty
          ? 'Respuesta registrada correctamente.'
          : response.message,
    );

    _cargarAsignaciones();
  }

  void _mensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String _etiqueta(String valor) {
    return valor.replaceAll('_', ' ');
  }

  // *********************************************************
  // UI
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgramacionesBloc, ProgramacionesState>(
      listenWhen: (anterior, actual) =>
          anterior.respuestaAsignacion != actual.respuestaAsignacion,
      listener: _onRespuesta,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis programaciones')),
        body: BlocBuilder<ProgramacionesBloc, ProgramacionesState>(
          builder: (context, state) {
            return ProgramacionesContent(
              state: state,
              fechaDesde: _fechaDesde,
              fechaHasta: _fechaHasta,
              estadoAsignacion: _estadoAsignacion,
              estadoProgramacion: _estadoProgramacion,
              onActualizar: _cargarAsignaciones,
              onSeleccionarFechas: _seleccionarFechas,
              onMostrarHoy: _mostrarHoy,
              onLimpiarFiltros: _limpiarFiltros,
              onCambiarPagina: _cambiarPagina,
              onResponder: _responderAsignacion,
            );
          },
        ),
      ),
    );
  }
}
