import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'ciudadano_calendario_event.dart';
import 'ciudadano_calendario_state.dart';

class CiudadanoCalendarioBloc
    extends Bloc<CiudadanoCalendarioEvent, CiudadanoCalendarioState> {
  final DomiciliosUseCases domiciliosUseCases;
  final int idDomicilio;

  int _requestId = 0;

  CiudadanoCalendarioBloc({
    required this.domiciliosUseCases,
    required this.idDomicilio,
    required DateTime mesInicial,
  }) : super(
         CiudadanoCalendarioState(
           mes: DateTime.utc(mesInicial.year, mesInicial.month, 1),
         ),
       ) {
    on<CiudadanoCalendarioRequested>(_onRequested);
  }

  String _fecha(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _onRequested(
    CiudadanoCalendarioRequested event,
    Emitter<CiudadanoCalendarioState> emit,
  ) async {
    final requestId = ++_requestId;

    final mes = DateTime.utc(event.mes.year, event.mes.month, 1);

    final ultimoDia = DateTime.utc(mes.year, mes.month + 1, 0);

    final fechaDesde = _fecha(mes);
    final fechaHasta = _fecha(ultimoDia);

    bool isCurrent() => !isClosed && !emit.isDone && requestId == _requestId;

    emit(
      CiudadanoCalendarioState(
        mes: mes,
        status: CiudadanoCalendarioStatus.loading,
      ),
    );

    try {
      final resource = await domiciliosUseCases.getDomicilioCronograma.run(
        idDomicilio: idDomicilio,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );

      if (!isCurrent()) return;

      if (resource is ErrorData<ApiResponse<GetDomicilioCronogramaDataModel>>) {
        emit(
          CiudadanoCalendarioState(
            mes: mes,
            status: CiudadanoCalendarioStatus.failure,
            errorMessage: resource.message,
            statusCode: resource.statusCode,
          ),
        );
        return;
      }

      if (resource is! Success<ApiResponse<GetDomicilioCronogramaDataModel>>) {
        throw const FormatException('No se recibió una respuesta válida.');
      }

      final api = resource.data;
      final data = api.data;

      if (!api.success ||
          data == null ||
          data.domicilio.idDomicilio != idDomicilio ||
          data.periodo.fechaDesde != fechaDesde ||
          data.periodo.fechaHasta != fechaHasta) {
        throw const FormatException(
          'El calendario no corresponde a la consulta.',
        );
      }

      emit(
        CiudadanoCalendarioState(
          mes: mes,
          status: CiudadanoCalendarioStatus.ready,
          cronograma: data,
        ),
      );
    } catch (_) {
      if (!isCurrent()) return;

      emit(
        CiudadanoCalendarioState(
          mes: mes,
          status: CiudadanoCalendarioStatus.failure,
          errorMessage:
              'No se pudo consultar el calendario. Intenta nuevamente.',
        ),
      );
    }
  }
}
