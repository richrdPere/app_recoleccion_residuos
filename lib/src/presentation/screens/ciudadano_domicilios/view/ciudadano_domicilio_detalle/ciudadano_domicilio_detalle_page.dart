import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

import 'ciudadano_domicilio_detalle_content.dart';

class CiudadanoDomicilioDetallePage extends StatelessWidget {
  final GetMisDomiciliosDataModel domicilio;

  const CiudadanoDomicilioDetallePage({super.key, required this.domicilio});

  @override
  Widget build(BuildContext context) {
    return CiudadanoDomicilioDetalleContent(
      domicilio: domicilio,
      onClose: () => Navigator.of(context).pop(),
    );
  }
}
