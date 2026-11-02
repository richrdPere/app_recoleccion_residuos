import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

import 'package:app_recoleccion_residuos/src/domain/use_cases/domicilios/domicilios_use_cases/GetMisDomiciliosUC.dart';
import 'package:app_recoleccion_residuos/src/domain/use_cases/domicilios/domicilios_use_cases/GetDomicilioServicioActivoUC.dart';

import 'ciudadano_mapa_event.dart';
import 'ciudadano_mapa_state.dart';

class CiudadanoMapaBloc extends Bloc<CiudadanoMapaEvent, CiudadanoMapaState> {
  final GetMisDomiciliosUC getMisDomicilios;
  final GetDomicilioServicioActivoUC getDomicilioServicioActivo;

  int _versionConsulta = 0;

  CiudadanoMapaBloc({
    required this.getMisDomicilios,
    required this.getDomicilioServicioActivo,
  }) : super(const CiudadanoMapaState()) {
    on<CiudadanoMapaRequested>(_onRequested);
    on<CiudadanoMapaDomicilioSelected>(_onDomicilioSelected);
    on<CiudadanoMapaServicioRequested>(_onServicioRequested);
    on<CiudadanoMapaReset>(_onReset);
  }

  bool _vigente(Emitter<CiudadanoMapaState> emit, int version) {
    return !emit.isDone && version == _versionConsulta;
  }

  // *********************************************************
  // CONSULTAR DOMICILIOS Y SERVICIO
  // *********************************************************

  Future<void> _onRequested(
    CiudadanoMapaRequested event,
    Emitter<CiudadanoMapaState> emit,
  ) async {
    if (state.isBusy) return;

    final version = ++_versionConsulta;
    final seleccionAnterior = state.idDomicilioSeleccionado;

    emit(
      CiudadanoMapaState(
        status: CiudadanoMapaStatus.cargandoDomicilios,
        domicilios: state.domicilios,
        idDomicilioSeleccionado: seleccionAnterior,
      ),
    );

    try {
      final resultado = await getMisDomicilios.run(incluirInactivos: false);

      if (!_vigente(emit, version)) return;

      if (resultado
          is ErrorData<ApiResponse<List<GetMisDomiciliosDataModel>>>) {
        _errorDomicilios(emit, resultado.message);
        return;
      }

      if (resultado is! Success<ApiResponse<List<GetMisDomiciliosDataModel>>>) {
        _errorDomicilios(
          emit,
          'No se recibió una respuesta válida de domicilios.',
        );
        return;
      }

      final api = resultado.data;
      final items = api.data;

      if (!api.success || items == null) {
        _errorDomicilios(emit, 'El servidor no devolvió tus domicilios.');
        return;
      }

      final domicilios = List<GetMisDomiciliosDataModel>.unmodifiable(items);

      GetMisDomiciliosDataModel? seleccionado;

      // Conservar la selección después de actualizar.
      for (final domicilio in domicilios) {
        if (domicilio.idDomicilio == seleccionAnterior) {
          seleccionado = domicilio;
          break;
        }
      }

      // En la primera consulta, preferir el domicilio principal.
      if (seleccionado == null) {
        for (final domicilio in domicilios) {
          if (domicilio.esPrincipal) {
            seleccionado = domicilio;
            break;
          }
        }
      }

      seleccionado ??= domicilios.isEmpty ? null : domicilios.first;

      if (seleccionado == null) {
        emit(const CiudadanoMapaState(status: CiudadanoMapaStatus.listo));
        return;
      }

      await _consultarServicio(
        emit,
        domicilios: domicilios,
        idDomicilio: seleccionado.idDomicilio,
        version: version,
      );
    } catch (_) {
      if (!_vigente(emit, version)) return;

      _errorDomicilios(
        emit,
        'No se pudieron consultar tus domicilios. '
        'Inténtalo nuevamente.',
      );
    }
  }

  // *********************************************************
  // CAMBIAR DOMICILIO
  // *********************************************************

  Future<void> _onDomicilioSelected(
    CiudadanoMapaDomicilioSelected event,
    Emitter<CiudadanoMapaState> emit,
  ) async {
    if (state.isBusy) return;

    final existe = state.domicilios.any(
      (domicilio) => domicilio.idDomicilio == event.idDomicilio,
    );

    if (!existe || event.idDomicilio == state.idDomicilioSeleccionado) {
      return;
    }

    final version = ++_versionConsulta;

    await _consultarServicio(
      emit,
      domicilios: state.domicilios,
      idDomicilio: event.idDomicilio,
      version: version,
    );
  }

  // *********************************************************
  // ACTUALIZAR SERVICIO
  // *********************************************************

  Future<void> _onServicioRequested(
    CiudadanoMapaServicioRequested event,
    Emitter<CiudadanoMapaState> emit,
  ) async {
    if (state.isBusy) return;

    final id = state.idDomicilioSeleccionado;
    if (id == null) return;

    final version = ++_versionConsulta;

    await _consultarServicio(
      emit,
      domicilios: state.domicilios,
      idDomicilio: id,
      version: version,
    );
  }

  Future<void> _consultarServicio(
    Emitter<CiudadanoMapaState> emit, {
    required List<GetMisDomiciliosDataModel> domicilios,
    required int idDomicilio,
    required int version,
  }) async {
    if (!_vigente(emit, version)) return;

    emit(
      CiudadanoMapaState(
        status: CiudadanoMapaStatus.cargandoServicio,
        domicilios: domicilios,
        idDomicilioSeleccionado: idDomicilio,
      ),
    );

    try {
      final resultado = await getDomicilioServicioActivo.run(
        idDomicilio: idDomicilio,
      );

      if (!_vigente(emit, version)) return;

      if (resultado
          is ErrorData<ApiResponse<GetDomicilioServicioActivoDataModel>>) {
        _errorServicio(emit, domicilios, idDomicilio, resultado.message);
        return;
      }

      if (resultado
          is! Success<ApiResponse<GetDomicilioServicioActivoDataModel>>) {
        _errorServicio(
          emit,
          domicilios,
          idDomicilio,
          'No se recibió una respuesta válida del servicio.',
        );
        return;
      }

      final api = resultado.data;
      final datos = api.data;

      if (!api.success ||
          datos == null ||
          datos.domicilio.idDomicilio != idDomicilio) {
        _errorServicio(
          emit,
          domicilios,
          idDomicilio,
          'La respuesta no corresponde al domicilio seleccionado.',
        );
        return;
      }

      emit(
        CiudadanoMapaState(
          status: CiudadanoMapaStatus.listo,
          domicilios: domicilios,
          idDomicilioSeleccionado: idDomicilio,
          datos: datos,
        ),
      );
    } catch (_) {
      if (!_vigente(emit, version)) return;

      _errorServicio(
        emit,
        domicilios,
        idDomicilio,
        'No se pudo consultar el servicio de recolección.',
      );
    }
  }

  // *********************************************************
  // ERRORES Y LIMPIEZA
  // *********************************************************

  void _errorDomicilios(Emitter<CiudadanoMapaState> emit, String mensaje) {
    emit(
      CiudadanoMapaState(
        status: CiudadanoMapaStatus.error,
        domicilios: state.domicilios,
        idDomicilioSeleccionado: state.idDomicilioSeleccionado,
        errorMessage: mensaje,
        errorEnDomicilios: true,
      ),
    );
  }

  void _errorServicio(
    Emitter<CiudadanoMapaState> emit,
    List<GetMisDomiciliosDataModel> domicilios,
    int idDomicilio,
    String mensaje,
  ) {
    emit(
      CiudadanoMapaState(
        status: CiudadanoMapaStatus.error,
        domicilios: domicilios,
        idDomicilioSeleccionado: idDomicilio,
        errorMessage: mensaje,
      ),
    );
  }

  void _onReset(CiudadanoMapaReset event, Emitter<CiudadanoMapaState> emit) {
    _versionConsulta++;
    emit(const CiudadanoMapaState());
  }
}
