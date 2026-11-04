import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

import '../bloc/ciudadano_preferencias_state.dart';

class CiudadanoPreferenciasContent extends StatefulWidget {
  final CiudadanoPreferenciasState state;

  final bool permiteAvisos;
  final String? versionConsentimiento;

  final VoidCallback onConsultar;

  final ValueChanged<UpdateCiudadanoPreferenciasRequest> onGuardar;

  const CiudadanoPreferenciasContent({
    super.key,
    required this.state,
    required this.permiteAvisos,
    this.versionConsentimiento,
    required this.onConsultar,
    required this.onGuardar,
  });

  @override
  State<CiudadanoPreferenciasContent> createState() =>
      _CiudadanoPreferenciasContentState();
}

class _CiudadanoPreferenciasContentState
    extends State<CiudadanoPreferenciasContent> {
  final _formKey = GlobalKey<FormState>();

  final _minutos = TextEditingController();

  final _opciones = <String, bool>{};

  String _frecuencia = 'SIEMPRE';

  bool _silencio = false;
  String? _inicio;
  String? _fin;

  static const _etiquetas = <String, String>{
    'canal_push': 'Avisos push en el dispositivo',
    'canal_interno': 'Avisos en la bandeja de la aplicación',
    'notificar_recordatorio': 'Recordatorios de recolección',
    'notificar_inicio_ruta': 'Inicio de ruta',
    'notificar_proximidad_vehiculo': 'Proximidad del vehículo',
    'notificar_cambio_horario': 'Cambios de horario',
    'notificar_cambio_ruta': 'Cambios de ruta',
    'notificar_cancelacion': 'Cancelaciones',
    'notificar_incidencias': 'Incidencias del servicio',
  };

  @override
  void initState() {
    super.initState();
    _precargar();
  }

  @override
  void didUpdateWidget(covariant CiudadanoPreferenciasContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.revision != widget.state.revision) {
      _precargar();
    }
  }

  void _precargar() {
    final preferencias = widget.state.preferencias;

    if (preferencias == null) return;

    final json = preferencias.toJson();

    for (final key in ['notificaciones_habilitadas', ..._etiquetas.keys]) {
      _opciones[key] = json[key] as bool;
    }

    _minutos.text = preferencias.minutosAnticipacion.toString();

    _frecuencia = preferencias.frecuenciaRecordatorio;

    _inicio = preferencias.horaSilencioInicio;
    _fin = preferencias.horaSilencioFin;

    _silencio = _inicio != null && _fin != null;
  }

  @override
  void dispose() {
    _minutos.dispose();
    super.dispose();
  }

  void _mensaje(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _elegirHora(bool inicio) async {
    if (widget.state.isBusy) return;

    final parts = (inicio ? _inicio : _fin)?.split(':');

    final seleccion = await showTimePicker(
      context: context,
      initialTime: parts == null
          ? const TimeOfDay(hour: 22, minute: 0)
          : TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );

    if (!mounted || seleccion == null) return;

    String dos(int value) => value.toString().padLeft(2, '0');

    final text =
        '${dos(seleccion.hour)}:'
        '${dos(seleccion.minute)}:00';

    setState(() {
      if (inicio) {
        _inicio = text;
      } else {
        _fin = text;
      }
    });
  }

  void _guardar() {
    if (widget.state.isBusy || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final habilitadas = _opciones['notificaciones_habilitadas'] ?? false;

    if (habilitadas && !widget.permiteAvisos) {
      _mensaje(
        'Revisa el consentimiento y el estado '
        'de tu perfil ciudadano.',
      );
      return;
    }

    if (habilitadas &&
        !(_opciones['canal_push'] ?? false) &&
        !(_opciones['canal_interno'] ?? false)) {
      _mensaje('Selecciona al menos un canal de aviso.');
      return;
    }

    if (_silencio && (_inicio == null || _fin == null || _inicio == _fin)) {
      _mensaje(
        'Selecciona ambas horas de silencio, '
        'distintas entre sí.',
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    widget.onGuardar(
      UpdateCiudadanoPreferenciasRequest(
        notificacionesHabilitadas: habilitadas,
        canalPush: _opciones['canal_push']!,
        canalInterno: _opciones['canal_interno']!,
        notificarRecordatorio: _opciones['notificar_recordatorio']!,
        notificarInicioRuta: _opciones['notificar_inicio_ruta']!,
        notificarProximidadVehiculo:
            _opciones['notificar_proximidad_vehiculo']!,
        notificarCambioHorario: _opciones['notificar_cambio_horario']!,
        notificarCambioRuta: _opciones['notificar_cambio_ruta']!,
        notificarCancelacion: _opciones['notificar_cancelacion']!,
        notificarIncidencias: _opciones['notificar_incidencias']!,
        minutosAnticipacion: int.parse(_minutos.text.trim()),
        frecuenciaRecordatorio: _frecuencia,
        horaSilencioInicio: _silencio ? _inicio : null,
        horaSilencioFin: _silencio ? _fin : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.preferencias == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              state.isBusy ||
                  state.status == CiudadanoPreferenciasStatus.initial
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ??
                          'No se pudieron consultar las preferencias.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: widget.onConsultar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isBusy) const LinearProgressIndicator(),

                Text(
                  'Tus avisos de recolección',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                Text(
                  widget.permiteAvisos
                      ? 'Perfil activo y consentimiento registrado.'
                      : 'Para habilitar avisos, revisa '
                            'tu perfil y el consentimiento.',
                ),

                if (widget.versionConsentimiento != null)
                  Text(
                    'Versión del consentimiento: '
                    '${widget.versionConsentimiento}',
                  ),

                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Habilitar notificaciones'),
                  value: _opciones['notificaciones_habilitadas'] ?? false,
                  onChanged: state.isBusy || !widget.permiteAvisos
                      ? null
                      : (value) {
                          setState(() {
                            _opciones['notificaciones_habilitadas'] = value;
                          });
                        },
                ),

                const Text(
                  'Los avisos push también requieren permiso '
                  'de notificación en el dispositivo.',
                ),

                const Divider(height: 28),

                ..._etiquetas.entries.map(
                  (entry) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.value),
                    value: _opciones[entry.key] ?? false,
                    onChanged: state.isBusy
                        ? null
                        : (value) {
                            setState(() {
                              _opciones[entry.key] = value;
                            });
                          },
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _minutos,
                  enabled: !state.isBusy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Anticipación del recordatorio (minutos)',
                    helperText: 'Entre 15 y 10080 minutos.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final minutes = int.tryParse(value?.trim() ?? '');

                    if (minutes == null || minutes < 15 || minutes > 10080) {
                      return 'Ingresa entre 15 y 10080 minutos.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  key: ValueKey(('frecuencia', state.revision)),
                  initialValue: _frecuencia,
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia del recordatorio',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SIEMPRE', child: Text('Siempre')),
                    DropdownMenuItem(
                      value: 'SOLO_UNA_VEZ',
                      child: Text('Solo una vez'),
                    ),
                  ],
                  onChanged: state.isBusy
                      ? null
                      : (value) {
                          if (value == null) return;

                          setState(() {
                            _frecuencia = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Horario de silencio'),
                  subtitle: const Text(
                    'Horario de Perú. Puede cruzar medianoche.',
                  ),
                  value: _silencio,
                  onChanged: state.isBusy
                      ? null
                      : (value) {
                          setState(() {
                            _silencio = value;
                          });
                        },
                ),

                if (_silencio)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: state.isBusy
                            ? null
                            : () => _elegirHora(true),
                        child: Text('Desde: ${_inicio ?? "Seleccionar"}'),
                      ),
                      OutlinedButton(
                        onPressed: state.isBusy
                            ? null
                            : () => _elegirHora(false),
                        child: Text('Hasta: ${_fin ?? "Seleccionar"}'),
                      ),
                    ],
                  ),

                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: state.isBusy ? null : _guardar,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    state.status == CiudadanoPreferenciasStatus.saving
                        ? 'Guardando…'
                        : 'Guardar preferencias',
                  ),
                ),

                TextButton(
                  onPressed: state.isBusy ? null : widget.onConsultar,
                  child: const Text('Descartar cambios y volver a consultar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
