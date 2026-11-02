import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/injection.dart';
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/use_cases/recorrido/RecorridoUseCases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_bloc.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_event.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_state.dart';

import 'recorrido_detalle_content.dart';

class RecorridoDetallePage extends StatelessWidget {
  final int idRecorrido;

  /// Información del listado para mostrar ruta y placa.
  /// El resto del detalle se consulta al backend.
  final MiRecorridoItemModel? resumenInicial;

  const RecorridoDetallePage({
    super.key,
    required this.idRecorrido,
    this.resumenInicial,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecorridoBloc>(
      create: (_) =>
          RecorridoBloc(locator<RecorridoUsecases>())
            ..add(ObtenerRecorridoDetalle(idRecorrido: idRecorrido)),
      child: _RecorridoDetalleView(
        idRecorrido: idRecorrido,
        resumenInicial: resumenInicial,
      ),
    );
  }
}

class _RecorridoDetalleView extends StatelessWidget {
  final int idRecorrido;
  final MiRecorridoItemModel? resumenInicial;

  const _RecorridoDetalleView({
    required this.idRecorrido,
    required this.resumenInicial,
  });

  Future<void> _actualizar(BuildContext context) async {
    final bloc = context.read<RecorridoBloc>();

    if (bloc.isClosed || bloc.state.isLoadingDetalle) return;

    // Nos suscribimos antes de enviar el evento.
    final completado = bloc.stream.firstWhere(
      (state) =>
          state.idDetalleSolicitado == idRecorrido &&
          (state.detalleResponse is Success<ApiResponse<RecorridoDataModel?>> ||
              state.detalleResponse
                  is ErrorData<ApiResponse<RecorridoDataModel?>>),
    );

    bloc.add(ObtenerRecorridoDetalle(idRecorrido: idRecorrido));

    try {
      await completado;
    } on StateError {
      // La pantalla se cerró antes de terminar la consulta.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecorridoBloc, RecorridoState>(
      builder: (context, state) {
        final response = state.detalleResponse;

        final error = response is ErrorData<ApiResponse<RecorridoDataModel?>>
            ? response.message
            : null;

        final detalle = state.recorridoDetalle;

        return RecorridoDetalleContent(
          idRecorrido: idRecorrido,
          recorrido: detalle?.idRecorrido == idRecorrido ? detalle : null,
          resumenInicial: resumenInicial?.idRecorrido == idRecorrido
              ? resumenInicial
              : null,
          cargando: response == null || state.isLoadingDetalle,
          error: error,
          onActualizar: () => _actualizar(context),
        );
      },
    );
  }
}
