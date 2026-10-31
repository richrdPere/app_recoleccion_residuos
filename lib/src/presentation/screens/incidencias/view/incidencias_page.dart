import 'dart:async';
import 'package:flutter/material.dart';

// Resource
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Content
import 'incidencias_content.dart';

class IncidenciasPage extends StatefulWidget {
  /// Retornar true cuando se haya creado una incidencia.
  final Future<bool?> Function()? onCrearIncidencia;

  /// Retornar true cuando el detalle haya modificado datos.
  final Future<bool?> Function(int idIncidencia)? onVerIncidencia;

  const IncidenciasPage({
    super.key,
    this.onCrearIncidencia,
    this.onVerIncidencia,
  });

  @override
  State<IncidenciasPage> createState() => _IncidenciasPageState();
}

class _IncidenciasPageState extends State<IncidenciasPage> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  Completer<void>? _refreshCompleter;

  int _page = 1;
  final int _limit = 10;

  String _tipo = '';
  String _prioridad = '';
  String _estado = '';

  bool _abriendoPantalla = false;

  // *********************************************************
  // CICLO DE VIDA
  // *********************************************************

  @override
  void initState() {
    super.initState();
    _cargarIncidencias();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _completarRefresh();

    _searchController.dispose();

    super.dispose();
  }

  // *********************************************************
  // OBTENER DATA DEL RESULTADO
  // *********************************************************

  IncidenciasPaginadasDataModel? _obtenerData(IncidenciasState state) {
    final resultado = state.listado.resultado;

    if (resultado is Success<IncidenciasListadoResponse>) {
      return resultado.data.data;
    }

    return null;
  }

  // *********************************************************
  // CONSULTAR LISTADO
  // *********************************************************

  void _cargarIncidencias() {
    if (!mounted) {
      return;
    }

    _searchDebounce?.cancel();

    final search = _searchController.text.trim();

    context.read<IncidenciasBloc>().add(
      ObtenerIncidenciasPaginadas(
        filters: IncidenciasPaginadasFilters(
          page: _page,
          limit: _limit,
          search: search.isEmpty ? null : search,
          tipo: _tipo.isEmpty ? null : _tipo,
          prioridad: _prioridad.isEmpty ? null : _prioridad,
          estadoIncidencia: _estado.isEmpty ? null : _estado,
          estado: true,
          sortBy: 'fecha_reporte',
          sortOrder: 'DESC',
        ),
      ),
    );
  }

  // *********************************************************
  // ACTUALIZACIÓN POR DESLIZAMIENTO
  // *********************************************************

  Future<void> _refrescar() {
    final pendiente = _refreshCompleter;

    if (pendiente != null) {
      return pendiente.future;
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;

    final cargando = context.read<IncidenciasBloc>().state.listado.estaCargando;

    if (!cargando) {
      _page = 1;
      _cargarIncidencias();
    }

    return completer.future;
  }

  void _completarRefresh() {
    final completer = _refreshCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }

    _refreshCompleter = null;
  }

  // *********************************************************
  // BÚSQUEDA
  // *********************************************************

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    // Actualiza la visibilidad del botón para limpiar filtros.
    setState(() {});

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }

      _page = 1;
      _cargarIncidencias();
    });
  }

  // *********************************************************
  // FILTROS
  // *********************************************************

  void _cambiarFiltros({String? tipo, String? prioridad, String? estado}) {
    _searchDebounce?.cancel();

    setState(() {
      if (tipo != null) {
        _tipo = tipo;
      }

      if (prioridad != null) {
        _prioridad = prioridad;
      }

      if (estado != null) {
        _estado = estado;
      }

      _page = 1;
    });

    _cargarIncidencias();
  }

  void _limpiarFiltros() {
    _searchDebounce?.cancel();

    setState(() {
      _searchController.clear();

      _tipo = '';
      _prioridad = '';
      _estado = '';

      _page = 1;
    });

    _cargarIncidencias();
  }

  bool get _hayFiltros {
    return _searchController.text.trim().isNotEmpty ||
        _tipo.isNotEmpty ||
        _prioridad.isNotEmpty ||
        _estado.isNotEmpty;
  }

  // *********************************************************
  // PAGINACIÓN
  // *********************************************************

  void _cambiarPagina(int nuevaPagina) {
    final bloc = context.read<IncidenciasBloc>();

    if (bloc.state.listado.estaCargando) {
      return;
    }

    final data = _obtenerData(bloc.state);

    if (data == null ||
        nuevaPagina < 1 ||
        nuevaPagina > data.pagination.totalPages ||
        nuevaPagina == data.pagination.page) {
      return;
    }

    _page = nuevaPagina;
    _cargarIncidencias();
  }

  // *********************************************************
  // NAVEGACIÓN: CREAR
  // *********************************************************

  Future<void> _abrirCreacion() async {
    final callback = widget.onCrearIncidencia;

    if (callback == null || _abriendoPantalla) {
      return;
    }

    setState(() {
      _abriendoPantalla = true;
    });

    try {
      final creada = await callback();

      if (!mounted) {
        return;
      }

      if (creada == true) {
        _page = 1;
        _cargarIncidencias();
      }
    } finally {
      if (mounted) {
        setState(() {
          _abriendoPantalla = false;
        });
      }
    }
  }

  // *********************************************************
  // NAVEGACIÓN: DETALLE
  // *********************************************************

  Future<void> _abrirDetalle(int idIncidencia) async {
    final callback = widget.onVerIncidencia;

    if (callback == null || _abriendoPantalla) {
      return;
    }

    setState(() {
      _abriendoPantalla = true;
    });

    try {
      final actualizada = await callback(idIncidencia);

      if (!mounted) {
        return;
      }

      if (actualizada == true) {
        _cargarIncidencias();
      }
    } finally {
      if (mounted) {
        setState(() {
          _abriendoPantalla = false;
        });
      }
    }
  }

  // *********************************************************
  // BUILD
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
        actions: [
          IconButton(
            tooltip: 'Actualizar incidencias',
            onPressed: () {
              unawaited(_refrescar());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: widget.onCrearIncidencia == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _abriendoPantalla ? null : _abrirCreacion,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Reportar'),
            ),
      body: BlocConsumer<IncidenciasBloc, IncidenciasState>(
        listenWhen: (previous, current) => previous.listado != current.listado,
        listener: (context, state) {
          if (!state.listado.estaCargando) {
            _completarRefresh();
          }

          final data = _obtenerData(state);

          if (state.listado.tieneExito && data != null) {
            _page = data.pagination.page;
          }
        },
        buildWhen: (previous, current) => previous.listado != current.listado,
        builder: (context, state) {
          final data = _obtenerData(state);

          return IncidenciasContent(
            incidencias: data?.items ?? const <IncidenciaListadoModel>[],
            pagination: data?.pagination,
            isLoading: state.listado.estaCargando,
            errorMessage: state.listado.mensajeError,
            searchController: _searchController,
            tipo: _tipo,
            prioridad: _prioridad,
            estado: _estado,
            hayFiltros: _hayFiltros,
            onSearchChanged: _onSearchChanged,
            onTipoChanged: (value) {
              _cambiarFiltros(tipo: value);
            },
            onPrioridadChanged: (value) {
              _cambiarFiltros(prioridad: value);
            },
            onEstadoChanged: (value) {
              _cambiarFiltros(estado: value);
            },
            onLimpiarFiltros: _limpiarFiltros,
            onRefresh: _refrescar,
            onReintentar: _cargarIncidencias,
            onCambiarPagina: _cambiarPagina,
            onVerIncidencia: widget.onVerIncidencia == null || _abriendoPantalla
                ? null
                : _abrirDetalle,
          );
        },
      ),
    );
  }
}
