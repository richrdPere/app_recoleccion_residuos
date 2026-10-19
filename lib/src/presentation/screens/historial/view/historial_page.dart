import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

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
  bool _solicitudPendiente = false;
  int? _paginaFallida;

  // *********************************************************
  // 1. CONSULTA INICIAL
  // *********************************************************
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<RecorridoBloc>();

      // Conserva la página actual si ya existe historial.
      final page = bloc.state.historial?.pagination.currentPage ?? 1;

      _consultarPagina(page);
    });
  }

  // *********************************************************
  // 2. CONSULTAR PÁGINA
  // *********************************************************
  Future<void> _consultarPagina(int page) async {
    final bloc = context.read<RecorridoBloc>();

    if (bloc.isClosed || page < 1 || _solicitudPendiente) return;

    setState(() => _solicitudPendiente = true);

    try {
      // Si otra pantalla inició una consulta, espera su resultado.
      if (bloc.state.isLoadingHistorial) {
        await bloc.stream.firstWhere(
          (state) =>
              state.historialResponse
                  is Success<ApiResponse<MisRecorridosDataModel>> ||
              state.historialResponse
                  is ErrorData<ApiResponse<MisRecorridosDataModel>>,
        );

        if (!mounted || bloc.isClosed) return;
      }

      // Suscribirse antes de enviar el evento.
      final completion = bloc.stream.firstWhere(
        (state) =>
            state.historialResponse
                is Success<ApiResponse<MisRecorridosDataModel>> ||
            state.historialResponse
                is ErrorData<ApiResponse<MisRecorridosDataModel>>,
      );

      bloc.add(ObtenerMisRecorridos(page: page, limit: bloc.state.limit));

      final result = await completion;

      if (!mounted) return;

      _paginaFallida =
          result.historialResponse
              is ErrorData<ApiResponse<MisRecorridosDataModel>>
          ? page
          : null;
    } on StateError {
      // El Bloc pudo cerrarse durante la consulta.
    } finally {
      if (mounted) {
        setState(() => _solicitudPendiente = false);
      }
    }
  }

  // *********************************************************
  // 3. ACTUALIZAR / REINTENTAR
  // *********************************************************
  Future<void> _refresh() async {
    final state = context.read<RecorridoBloc>().state;

    await _consultarPagina(
      _paginaFallida ?? state.historial?.pagination.currentPage ?? 1,
    );
  }

  // *********************************************************
  // 4. CAMBIAR PÁGINA
  // *********************************************************
  Future<void> _cambiarPagina(int page) async {
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

  // *********************************************************
  // 5. INTERFAZ Y MENSAJES
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecorridoBloc, RecorridoState>(
      listenWhen: (previous, current) {
        return !identical(
          previous.historialResponse,
          current.historialResponse,
        );
      },
      listener: (context, state) {
        final response = state.historialResponse;

        // Con datos previos, el Content conserva la lista
        // y el listener comunica el fallo.
        if (response is ErrorData<ApiResponse<MisRecorridosDataModel>> &&
            state.historial != null) {
          final messenger = ScaffoldMessenger.of(context);

          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(response.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return HistorialContent(
          state: state,
          solicitudPendiente: _solicitudPendiente,
          onRefresh: _refresh,
          onPageChanged: _cambiarPagina,
        );
      },
    );
  }
}
