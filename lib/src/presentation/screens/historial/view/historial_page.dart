import 'dart:async';

import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/view/recorrido_detalle/recorrido_detalle_page.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/view/widgets/historial_filtros_sheet.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';
import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_bloc.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_state.dart';

import 'historial_content.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  HistorialFiltros _filtros = const HistorialFiltros();

  bool _solicitudPendiente = false;
  bool _modalAbierto = false;

  int? _paginaFallida;

  bool get _isBusy =>
      _solicitudPendiente ||
      _modalAbierto ||
      context.read<RecorridoBloc>().state.isLoadingHistorial;

  String? get _userId {
    final state = context.read<SessionBloc>().state;

    return state.isAuthenticated
        ? state.session!.usuario.idUsuario.toString()
        : null;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _consultarPagina(1);
      }
    });
  }

  Future<void> _consultarPagina(int page) async {
    final bloc = context.read<RecorridoBloc>();

    if (bloc.isClosed || page < 1 || _solicitudPendiente) {
      return;
    }

    setState(() => _solicitudPendiente = true);

    try {
      // Esperar una consulta previa de este BLoC compartido.
      if (bloc.state.isLoadingHistorial) {
        await bloc.stream
            .timeout(const Duration(seconds: 45))
            .firstWhere(
              (state) =>
                  state.historialResponse
                      is Success<ApiResponse<MisRecorridosDataModel>> ||
                  state.historialResponse
                      is ErrorData<ApiResponse<MisRecorridosDataModel>>,
            );

        if (!mounted || bloc.isClosed) return;
      }

      // Esperar primero la carga de la nueva consulta y
      // después su resultado. No aceptar un éxito previo.
      final completion = bloc.stream
          .timeout(const Duration(seconds: 45))
          .map((state) => state.historialResponse)
          .skipWhile(
            (response) =>
                response is! Loading<ApiResponse<MisRecorridosDataModel>>,
          )
          .firstWhere(
            (response) =>
                response is Success<ApiResponse<MisRecorridosDataModel>> ||
                response is ErrorData<ApiResponse<MisRecorridosDataModel>>,
          );

      bloc.add(
        ObtenerMisRecorridos(
          page: page,
          limit: bloc.state.limit,
          filtros: _filtros,
        ),
      );

      final result = await completion;

      if (!mounted) return;

      _paginaFallida = result is ErrorData<ApiResponse<MisRecorridosDataModel>>
          ? page
          : null;
    } on TimeoutException {
      if (mounted) {
        _paginaFallida = page;
        _mensaje('La consulta está tardando demasiado. Inténtalo nuevamente.');
      }
    } on StateError {
      // El BLoC pudo cerrarse durante la consulta.
    } finally {
      if (mounted) {
        setState(() => _solicitudPendiente = false);
      }
    }
  }

  Future<void> _refresh() async {
    final state = context.read<RecorridoBloc>().state;

    await _consultarPagina(
      _paginaFallida ?? state.historial?.pagination.currentPage ?? 1,
    );
  }

  Future<void> _cambiarPagina(int page) async {
    if (_isBusy) return;

    final pagination = context
        .read<RecorridoBloc>()
        .state
        .historial
        ?.pagination;

    if (pagination == null ||
        page < 1 ||
        page > pagination.totalPages ||
        page == pagination.currentPage) {
      return;
    }

    await _consultarPagina(page);
  }

  Future<void> _aplicarFiltros(HistorialFiltros filtros) async {
    if (!mounted || _isBusy || filtros == _filtros) return;

    setState(() {
      _filtros = filtros;
      _paginaFallida = null;
    });

    // Cualquier búsqueda o cambio de filtros comienza en página 1.
    await _consultarPagina(1);
  }

  Future<void> _abrirRecorrido(MiRecorridoItemModel recorrido) async {
    if (_isBusy) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RecorridoDetallePage(
          idRecorrido: recorrido.idRecorrido,
          resumenInicial: recorrido,
        ),
      ),
    );
  }

  Future<void> _abrirBusqueda() async {
    if (_isBusy) return;

    final userId = _userId;

    if (userId == null) return;

    setState(() => _modalAbierto = true);

    String? resultado;

    try {
      resultado = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => AppSearchPage(
            userId: userId,
            historyScope: 'recorridos.historial',
            initialQuery: _filtros.search,
            hintText: 'Buscar ruta, placa o número',
            emptyTitle: 'Busca en tu historial',
            emptyDescription:
                'Escribe el nombre o código de una ruta, '
                'una placa o un número de recorrido.',
            resultsSubtitle: 'Consultar mis recorridos',
            allowEmptyQuery: true,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _modalAbierto = false);
      }
    }

    if (!mounted ||
        _userId != userId ||
        resultado == null ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    await _aplicarFiltros(_filtros.copyWith(search: resultado.trim()));
  }

  Future<void> _abrirFiltros() async {
    if (_isBusy) return;

    final userId = _userId;

    if (userId == null) return;

    setState(() => _modalAbierto = true);

    HistorialFiltros? resultado;

    try {
      resultado = await showModalBottomSheet<HistorialFiltros>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.90,
        ),
        builder: (_) => HistorialFiltrosSheet(filtros: _filtros),
      );
    } finally {
      if (mounted) {
        setState(() => _modalAbierto = false);
      }
    }

    if (!mounted ||
        _userId != userId ||
        resultado == null ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    await _aplicarFiltros(resultado);
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecorridoBloc, RecorridoState>(
      listenWhen: (previous, current) =>
          !identical(previous.historialResponse, current.historialResponse),
      listener: (context, state) {
        final response = state.historialResponse;

        if (response is ErrorData<ApiResponse<MisRecorridosDataModel>> &&
            state.historial != null) {
          _mensaje(response.message);
        }
      },
      builder: (context, state) {
        return HistorialContent(
          state: state,
          solicitudPendiente: _solicitudPendiente || _modalAbierto,
          onAbrirRecorrido: _abrirRecorrido,
          onRefresh: _refresh,
          onPageChanged: _cambiarPagina,

          filtros: _filtros,
          onBuscar: _abrirBusqueda,
          onAbrirFiltros: _abrirFiltros,

          onQuitarBusqueda: () {
            _aplicarFiltros(_filtros.copyWith(search: ''));
          },

          onLimpiarFiltros: () {
            _aplicarFiltros(HistorialFiltros(search: _filtros.search));
          },
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:app_recoleccion_residuos/src/data/models/models.dart';
// import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

// import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_bloc.dart';
// import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_event.dart';
// import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_state.dart';

// import 'historial_content.dart';

// class HistorialPage extends StatefulWidget {
//   const HistorialPage({super.key});

//   @override
//   State<HistorialPage> createState() => _HistorialPageState();
// }

// class _HistorialPageState extends State<HistorialPage> {
//   bool _solicitudPendiente = false;
//   int? _paginaFallida;

//   // *********************************************************
//   // 1. CONSULTA INICIAL
//   // *********************************************************
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       final bloc = context.read<RecorridoBloc>();

//       // Conserva la página actual si ya existe historial.
//       final page = bloc.state.historial?.pagination.currentPage ?? 1;

//       _consultarPagina(page);
//     });
//   }

//   // *********************************************************
//   // 2. CONSULTAR PÁGINA
//   // *********************************************************
//   Future<void> _consultarPagina(int page) async {
//     final bloc = context.read<RecorridoBloc>();

//     if (bloc.isClosed || page < 1 || _solicitudPendiente) return;

//     setState(() => _solicitudPendiente = true);

//     try {
//       // Si otra pantalla inició una consulta, espera su resultado.
//       if (bloc.state.isLoadingHistorial) {
//         await bloc.stream.firstWhere(
//           (state) =>
//               state.historialResponse
//                   is Success<ApiResponse<MisRecorridosDataModel>> ||
//               state.historialResponse
//                   is ErrorData<ApiResponse<MisRecorridosDataModel>>,
//         );

//         if (!mounted || bloc.isClosed) return;
//       }

//       // Suscribirse antes de enviar el evento.
//       final completion = bloc.stream.firstWhere(
//         (state) =>
//             state.historialResponse
//                 is Success<ApiResponse<MisRecorridosDataModel>> ||
//             state.historialResponse
//                 is ErrorData<ApiResponse<MisRecorridosDataModel>>,
//       );

//       bloc.add(ObtenerMisRecorridos(page: page, limit: bloc.state.limit));

//       final result = await completion;

//       if (!mounted) return;

//       _paginaFallida =
//           result.historialResponse
//               is ErrorData<ApiResponse<MisRecorridosDataModel>>
//           ? page
//           : null;
//     } on StateError {
//       // El Bloc pudo cerrarse durante la consulta.
//     } finally {
//       if (mounted) {
//         setState(() => _solicitudPendiente = false);
//       }
//     }
//   }

//   // *********************************************************
//   // 3. ACTUALIZAR / REINTENTAR
//   // *********************************************************
//   Future<void> _refresh() async {
//     final state = context.read<RecorridoBloc>().state;

//     await _consultarPagina(
//       _paginaFallida ?? state.historial?.pagination.currentPage ?? 1,
//     );
//   }

//   // *********************************************************
//   // 4. CAMBIAR PÁGINA
//   // *********************************************************
//   Future<void> _cambiarPagina(int page) async {
//     final pagination = context
//         .read<RecorridoBloc>()
//         .state
//         .historial
//         ?.pagination;

//     if (pagination == null ||
//         page < 1 ||
//         page > pagination.totalPages ||
//         page == pagination.currentPage) {
//       return;
//     }

//     await _consultarPagina(page);
//   }

//   // *********************************************************
//   // 5. INTERFAZ Y MENSAJES
//   // *********************************************************
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<RecorridoBloc, RecorridoState>(
//       listenWhen: (previous, current) {
//         return !identical(
//           previous.historialResponse,
//           current.historialResponse,
//         );
//       },
//       listener: (context, state) {
//         final response = state.historialResponse;

//         // Con datos previos, el Content conserva la lista
//         // y el listener comunica el fallo.
//         if (response is ErrorData<ApiResponse<MisRecorridosDataModel>> &&
//             state.historial != null) {
//           final messenger = ScaffoldMessenger.of(context);

//           messenger.hideCurrentSnackBar();
//           messenger.showSnackBar(
//             SnackBar(
//               content: Text(response.message),
//               behavior: SnackBarBehavior.floating,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return HistorialContent(
//           state: state,
//           solicitudPendiente: _solicitudPendiente,
//           onRefresh: _refresh,
//           onPageChanged: _cambiarPagina,
//         );
//       },
//     );
//   }
// }
