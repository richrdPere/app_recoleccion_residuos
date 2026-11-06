import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/config/core/session/session_bloc.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_bloc.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/recorrido/bloc/recorrido_event.dart';

import 'operacion_offline.dart';

class OperacionOfflineScope extends StatefulWidget {
  final Widget child;

  const OperacionOfflineScope({super.key, required this.child});

  @override
  State<OperacionOfflineScope> createState() => _OperacionOfflineScopeState();
}

class _OperacionOfflineScopeState extends State<OperacionOfflineScope> {
  final operacion = OperacionOffline.instance;

  @override
  void initState() {
    super.initState();

    final recorrido = context.read<RecorridoBloc>();

    operacion.onRecorridoSincronizado = () {
      if (!recorrido.isClosed) {
        recorrido.add(const ObtenerRecorridoActivo());
      }
    };

    unawaited(
      operacion.vincular(context.read<SessionBloc>()).catchError((
        Object error,
      ) {
        operacion.informar('No se pudo preparar la operación local: $error');
      }),
    );
  }

  @override
  void dispose() {
    operacion.onRecorridoSincronizado = null;
    unawaited(operacion.desvincular());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
