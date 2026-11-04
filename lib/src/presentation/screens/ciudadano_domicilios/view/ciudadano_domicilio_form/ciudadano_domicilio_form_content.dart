import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class CiudadanoDomicilioFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final bool editando;
  final bool inicializado;
  final bool guardando;
  final bool bloqueado;
  final String? errorInicial;

  final TextEditingController nombre;
  final TextEditingController direccion;
  final TextEditingController referencia;
  final TextEditingController observacion;

  final double? latitud;
  final double? longitud;

  final bool principal;
  final int? idZona;
  final int? idRuta;

  final ResolverCoberturaDataModel? cobertura;
  final bool cargandoCobertura;
  final String? errorCobertura;
  final bool puedeGuardar;

  final ValueChanged<bool> onPrincipal;
  final ValueChanged<int?> onZona;
  final ValueChanged<int?> onRuta;

  final VoidCallback onUbicacion;
  final VoidCallback onConsultarCobertura;
  final VoidCallback onGuardar;
  final VoidCallback onReintentar;
  final VoidCallback onBack;

  const CiudadanoDomicilioFormContent({
    super.key,
    required this.formKey,
    required this.editando,
    required this.inicializado,
    required this.guardando,
    required this.bloqueado,
    required this.errorInicial,
    required this.nombre,
    required this.direccion,
    required this.referencia,
    required this.observacion,
    required this.latitud,
    required this.longitud,
    required this.principal,
    required this.idZona,
    required this.idRuta,
    required this.cobertura,
    required this.cargandoCobertura,
    required this.errorCobertura,
    required this.puedeGuardar,
    required this.onPrincipal,
    required this.onZona,
    required this.onRuta,
    required this.onUbicacion,
    required this.onConsultarCobertura,
    required this.onGuardar,
    required this.onReintentar,
    required this.onBack,
  });

  String? _validarTexto(String? value, String campo, int minimo) {
    if (value == null || value.trim().length < minimo) {
      return '$campo debe tener al menos $minimo caracteres.';
    }

    return null;
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = cobertura;
    final zonas = data?.zonas ?? const <CoberturaZonaModel>[];

    CoberturaZonaModel? zonaSeleccionada;

    for (final zona in zonas) {
      if (zona.idZona == idZona) {
        zonaSeleccionada = zona;
        break;
      }
    }

    final rutas = zonaSeleccionada?.rutas ?? const <CoberturaRutaModel>[];

    final selectedZona = zonas.any((zona) => zona.idZona == idZona)
        ? idZona
        : null;

    final selectedRuta = rutas.any((ruta) => ruta.idRuta == idRuta)
        ? idRuta
        : null;

    final tieneUbicacion = latitud != null && longitud != null;

    return PopScope(
      canPop: !guardando,
      child: Scaffold(
        appBar: AppBar(
          title: Text(editando ? 'Editar domicilio' : 'Nuevo domicilio'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: guardando ? null : onBack,
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: !inicializado
              ? Center(
                  child: errorInicial == null
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(errorInicial!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: bloqueado ? null : onReintentar,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Datos del domicilio',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: nombre,
                              enabled: !bloqueado,
                              maxLength: 100,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: _decoration(
                                'Nombre: casa, trabajo…',
                                Icons.home_outlined,
                              ),
                              validator: (value) =>
                                  _validarTexto(value, 'El nombre', 2),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: direccion,
                              enabled: !bloqueado,
                              maxLength: 300,
                              maxLines: 2,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: _decoration(
                                'Dirección',
                                Icons.location_on_outlined,
                              ),
                              validator: (value) =>
                                  _validarTexto(value, 'La dirección', 5),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: referencia,
                              enabled: !bloqueado,
                              maxLength: 300,
                              maxLines: 2,
                              decoration: _decoration(
                                'Referencia (opcional)',
                                Icons.near_me_outlined,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Ubicación y cobertura',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Selecciona el punto de tu domicilio para '
                              'consultar la zona y sus rutas disponibles.',
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: bloqueado ? null : onUbicacion,
                              icon: const Icon(Icons.map_outlined),
                              label: Text(
                                tieneUbicacion
                                    ? 'Cambiar ubicación en el mapa'
                                    : 'Seleccionar ubicación en el mapa',
                              ),
                            ),
                            if (tieneUbicacion) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Latitud: ${latitud!.toStringAsFixed(7)}\n'
                                'Longitud: ${longitud!.toStringAsFixed(7)}',
                              ),
                              TextButton.icon(
                                onPressed: bloqueado || cargandoCobertura
                                    ? null
                                    : onConsultarCobertura,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Consultar cobertura'),
                              ),
                            ],
                            if (cargandoCobertura) ...[
                              const LinearProgressIndicator(),
                              const SizedBox(height: 8),
                              const Text('Consultando cobertura…'),
                            ],
                            if (errorCobertura != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                errorCobertura!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            if (data != null && !data.tieneCobertura) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Esta ubicación no tiene cobertura configurada. '
                                'Verifica el punto seleccionado.',
                              ),
                            ],
                            if (data != null && data.tieneCobertura) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                key: ValueKey(('zona', data, selectedZona)),
                                initialValue: selectedZona,
                                isExpanded: true,
                                decoration: _decoration(
                                  'Zona',
                                  Icons.grid_view_outlined,
                                ),
                                items: zonas
                                    .map(
                                      (zona) => DropdownMenuItem<int>(
                                        value: zona.idZona,
                                        child: Text(
                                          zona.nombre,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: bloqueado ? null : onZona,
                                validator: (value) => value == null
                                    ? 'Selecciona una zona.'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                key: ValueKey((
                                  'ruta',
                                  data,
                                  selectedZona,
                                  selectedRuta,
                                )),
                                initialValue: selectedRuta,
                                isExpanded: true,
                                decoration: _decoration(
                                  'Ruta',
                                  Icons.route_outlined,
                                ),
                                items: rutas
                                    .map(
                                      (ruta) => DropdownMenuItem<int>(
                                        value: ruta.idRuta,
                                        child: Text(
                                          ruta.nombre,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: bloqueado || selectedZona == null
                                    ? null
                                    : onRuta,
                                validator: (value) => value == null
                                    ? 'Selecciona una ruta.'
                                    : null,
                              ),
                              if (selectedZona != null && rutas.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'La zona no tiene rutas activas disponibles.',
                                  ),
                                ),
                              const SizedBox(height: 8),
                              const Text(
                                'Las rutas mostradas pertenecen a la zona. '
                                'Confirma cuál atiende tu domicilio.',
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (!editando)
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Domicilio principal'),
                                subtitle: const Text(
                                  'Si es tu primer domicilio activo, '
                                  'se establecerá como principal.',
                                ),
                                value: principal,
                                onChanged: bloqueado ? null : onPrincipal,
                              ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: observacion,
                              enabled: !bloqueado,
                              maxLines: 3,
                              maxLength: 1000,
                              decoration: _decoration(
                                'Observación (opcional)',
                                Icons.notes_outlined,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: puedeGuardar ? onGuardar : null,
                              icon: guardando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                guardando
                                    ? 'Guardando…'
                                    : editando
                                    ? 'Guardar cambios'
                                    : 'Registrar domicilio',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
