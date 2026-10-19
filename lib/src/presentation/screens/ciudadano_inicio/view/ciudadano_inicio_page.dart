import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'ciudadano_inicio_content.dart';

class CiudadanoInicioPage extends StatefulWidget {
  const CiudadanoInicioPage({super.key});

  @override
  State<CiudadanoInicioPage> createState() => _CiudadanoInicioPageState();
}

class _CiudadanoInicioPageState extends State<CiudadanoInicioPage> {
  // *********************************************************
  // 1. CARGAR AL ABRIR
  // *********************************************************

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadInicio();
    });
  }

  // *********************************************************
  // 2. ACTUALIZAR INICIO
  // *********************************************************

  void _loadInicio() {
    final bloc = context.read<CiudadanoInicioBloc>();

    if (bloc.state.isLoading) return;

    bloc.add(const CiudadanoInicioRequested());
  }

  // *********************************************************
  // 3. SELECCIONAR DOMICILIO
  // *********************************************************

  void _selectDomicilio(int idDomicilio) {
    context.read<CiudadanoInicioBloc>().add(
      CiudadanoInicioDomicilioSelected(idDomicilio: idDomicilio),
    );
  }

  // *********************************************************
  // 4. REINTENTAR CRONOGRAMA
  // *********************************************************

  void _retryCronograma() {
    context.read<CiudadanoInicioBloc>().add(
      const CiudadanoInicioCronogramaRequested(),
    );
  }

  // *********************************************************
  // 5. INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final nombres = context.select(
      (CiudadanoCuentaBloc bloc) => bloc.state.perfil?.usuario.persona.nombres,
    );

    return BlocBuilder<CiudadanoInicioBloc, CiudadanoInicioState>(
      builder: (context, state) {
        return CiudadanoInicioContent(
          state: state,
          nombres: nombres,
          onRefresh: _loadInicio,
          onSelectDomicilio: _selectDomicilio,
          onRetryCronograma: _retryCronograma,
          onOpenCuenta: () {
            context.go('/ciudadano/perfil');
          },
          onOpenMapa: () {
            context.go('/ciudadano/mapa');
          },
        );
      },
    );
  }
}
