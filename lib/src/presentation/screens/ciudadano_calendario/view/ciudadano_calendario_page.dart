import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/domain/uses_cases.dart';

import '../bloc/ciudadano_calendario_bloc.dart';
import '../bloc/ciudadano_calendario_event.dart';
import '../bloc/ciudadano_calendario_state.dart';

import 'ciudadano_calendario_content.dart';

class CiudadanoCalendarioPage extends StatelessWidget {
  final int idDomicilio;
  final DomiciliosUseCases domiciliosUseCases;

  const CiudadanoCalendarioPage({
    super.key,
    required this.idDomicilio,
    required this.domiciliosUseCases,
  });

  @override
  Widget build(BuildContext context) {
    final peru = DateTime.now().toUtc().subtract(const Duration(hours: 5));

    final mesInicial = DateTime.utc(peru.year, peru.month, 1);

    return BlocProvider(
      create: (_) => CiudadanoCalendarioBloc(
        domiciliosUseCases: domiciliosUseCases,
        idDomicilio: idDomicilio,
        mesInicial: mesInicial,
      )..add(CiudadanoCalendarioRequested(mes: mesInicial)),
      child: const _CalendarioView(),
    );
  }
}

class _CalendarioView extends StatelessWidget {
  const _CalendarioView();

  void _consultar(BuildContext context, DateTime mes) {
    context.read<CiudadanoCalendarioBloc>().add(
      CiudadanoCalendarioRequested(mes: mes),
    );
  }

  Future<void> _seleccionarMes(BuildContext context, DateTime mes) async {
    final seleccionado = await showDatePicker(
      context: context,
      initialDate: DateTime(mes.year, mes.month, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Selecciona una fecha del mes a consultar',
    );

    if (!context.mounted || seleccionado == null) return;

    _consultar(context, DateTime.utc(seleccionado.year, seleccionado.month, 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CiudadanoCalendarioBloc, CiudadanoCalendarioState>(
      builder: (context, state) {
        return CiudadanoCalendarioContent(
          state: state,
          onConsultarMes: (mes) => _consultar(context, mes),
          onSeleccionarMes: () {
            _seleccionarMes(context, state.mes);
          },
        );
      },
    );
  }
}
