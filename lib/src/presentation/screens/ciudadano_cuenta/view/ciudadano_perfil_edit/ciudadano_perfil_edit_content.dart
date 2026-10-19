import 'package:flutter/material.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class CiudadanoPerfilEditContent extends StatefulWidget {
  final GetCiudadanoPerfilDataModel perfil;
  final bool isBusy;
  final bool canSave;
  final String? errorMessage;

  final VoidCallback onRetry;
  final VoidCallback onCancel;
  final ValueChanged<UpdateCiudadanoPerfilRequest> onSave;

  const CiudadanoPerfilEditContent({
    super.key,
    required this.perfil,
    required this.isBusy,
    required this.canSave,
    required this.onRetry,
    required this.onCancel,
    required this.onSave,
    this.errorMessage,
  });

  @override
  State<CiudadanoPerfilEditContent> createState() =>
      _CiudadanoPerfilEditContentState();
}

class _CiudadanoPerfilEditContentState
    extends State<CiudadanoPerfilEditContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _observacionController;
  late final String _versionConsentimiento;

  late bool _aceptaTratamientoDatos;

  @override
  void initState() {
    super.initState();

    _observacionController = TextEditingController(
      text: widget.perfil.observacion ?? '',
    );

    _versionConsentimiento = widget.perfil.versionConsentimiento?.trim() ?? '';

    _aceptaTratamientoDatos = widget.perfil.aceptaTratamientoDatos;
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isBusy || !widget.canSave || _versionConsentimiento.isEmpty) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSave(
      UpdateCiudadanoPerfilRequest(
        aceptaTratamientoDatos: _aceptaTratamientoDatos,
        versionConsentimiento: _versionConsentimiento,

        // Cadena vacía para enviar explícitamente el campo vacío.
        observacion: _observacionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = !widget.isBusy && widget.canSave;

    return Column(
      children: [
        if (widget.isBusy) const LinearProgressIndicator(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.perfil.usuario.persona.nombreCompleto,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Actualiza las opciones de tu perfil ciudadano.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),

                      // ERROR DE CONSULTA O GUARDADO
                      if (widget.errorMessage != null) ...[
                        Card(
                          color: colors.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.errorMessage!,
                                  style: TextStyle(
                                    color: colors.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: widget.isBusy
                                      ? null
                                      : widget.onRetry,
                                  child: const Text(
                                    'Consultar estado del perfil',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // CONSENTIMIENTO
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tratamiento de datos',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),

                              // Incorporar aquí el acceso al texto
                              // institucional de esta versión.
                              Text(
                                _versionConsentimiento.isEmpty
                                    ? 'No se encontró la versión '
                                          'del consentimiento.'
                                    : 'Versión del consentimiento: '
                                          '$_versionConsentimiento',
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Acepto el tratamiento de mis '
                                  'datos personales',
                                ),
                                value: _aceptaTratamientoDatos,
                                onChanged: enabled
                                    ? (value) {
                                        setState(() {
                                          _aceptaTratamientoDatos = value;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // OBSERVACIÓN
                      TextFormField(
                        controller: _observacionController,
                        enabled: enabled,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Observación',
                          hintText: 'Información adicional (opcional)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      FilledButton(
                        onPressed: enabled && _versionConsentimiento.isNotEmpty
                            ? _submit
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                        ),
                        child: Text(
                          widget.isBusy ? 'Procesando…' : 'Guardar cambios',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.isBusy ? null : widget.onCancel,
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
