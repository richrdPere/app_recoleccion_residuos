import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Blocs
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Entities
import 'package:app_recoleccion_residuos/src/domain/entities/entities.dart';

class MapaPermisosPanel extends StatelessWidget {
  final bool ubicacionPendiente;
  final UbicacionEntity? ubicacion;

  final VoidCallback onSolicitarUbicacion;
  final VoidCallback onAbrirConfiguracionUbicacion;
  final VoidCallback onAbrirConfiguracionAplicacion;

  const MapaPermisosPanel({
    super.key,
    required this.ubicacionPendiente,
    required this.ubicacion,
    required this.onSolicitarUbicacion,
    required this.onAbrirConfiguracionUbicacion,
    required this.onAbrirConfiguracionAplicacion,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeolocatorBloc, GeolocatorState>(
      builder: (context, state) {
        final gps = state.servicioHabilitado;
        final permiso = state.permisoActual;

        final permisoBloqueado =
            permiso == PermisoUbicacion.denegadoPermanentemente;

        final precision = ubicacion?.precisionMetros;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ubicación del dispositivo',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            Text(
              'GPS: ${gps == null
                  ? 'Sin verificar'
                  : gps
                  ? 'Activado'
                  : 'Desactivado'}',
            ),
            const SizedBox(height: 4),
            Text('Permiso: ${_textoPermiso(permiso)}'),

            if (ubicacion != null) ...[
              const SizedBox(height: 8),
              Text(
                'Latitud: '
                '${ubicacion!.coordenada.latitud.toStringAsFixed(6)}',
              ),
              Text(
                'Longitud: '
                '${ubicacion!.coordenada.longitud.toStringAsFixed(6)}',
              ),
              if (precision != null)
                Text(
                  'Precisión reportada: '
                  '${precision.toStringAsFixed(1)} m',
                ),
            ],

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: ubicacionPendiente
                      ? null
                      : permisoBloqueado
                      ? onAbrirConfiguracionAplicacion
                      : onSolicitarUbicacion,
                  icon: ubicacionPendiente
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          permisoBloqueado
                              ? Icons.settings_outlined
                              : Icons.my_location,
                        ),
                  label: Text(
                    ubicacionPendiente
                        ? 'Obteniendo…'
                        : permisoBloqueado
                        ? 'Habilitar permiso'
                        : permiso == PermisoUbicacion.denegado
                        ? 'Permitir y ubicarme'
                        : 'Mi ubicación',
                  ),
                ),
                if (gps == false)
                  OutlinedButton.icon(
                    onPressed: ubicacionPendiente
                        ? null
                        : onAbrirConfiguracionUbicacion,
                    icon: const Icon(Icons.location_disabled),
                    label: const Text('Activar GPS'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _textoPermiso(PermisoUbicacion? permiso) {
    switch (permiso) {
      case PermisoUbicacion.denegado:
        return 'No concedido';
      case PermisoUbicacion.denegadoPermanentemente:
        return 'Bloqueado desde el sistema';
      case PermisoUbicacion.duranteUso:
        return 'Permitido durante el uso';
      case PermisoUbicacion.siempre:
        return 'Permitido siempre';
      case PermisoUbicacion.desconocido:
        return 'No se pudo determinar';
      case null:
        return 'Sin verificar';
    }
  }
}
