import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';

class CiudadanoPerfilFormContent extends StatefulWidget {
  final bool isSaving;
  final ValueChanged<CreateCiudadanoPerfilRequest> onSubmit;

  const CiudadanoPerfilFormContent({
    super.key,
    required this.isSaving,
    required this.onSubmit,
  });

  @override
  State<CiudadanoPerfilFormContent> createState() =>
      _CiudadanoPerfilFormContentState();
}

class _CiudadanoPerfilFormContentState
    extends State<CiudadanoPerfilFormContent> {
  // Debe coincidir con la versión del consentimiento presentado.
  static const String _versionConsentimiento = '1.0';

  bool _aceptaTratamientoDatos = false;
  bool _submitted = false;

  // *********************************************************
  // 1. CREAR PERFIL
  // *********************************************************

  void _submit() {
    if (widget.isSaving) return;

    setState(() {
      _submitted = true;
    });

    if (!_aceptaTratamientoDatos) return;

    FocusManager.instance.primaryFocus?.unfocus();

    widget.onSubmit(
      CreateCiudadanoPerfilRequest(
        aceptaTratamientoDatos: _aceptaTratamientoDatos,
        versionConsentimiento: _versionConsentimiento,
        origenRegistro: 'APP',
      ),
    );
  }

  // *********************************************************
  // 2. INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 48)
                  .clamp(0.0, double.infinity)
                  .toDouble(),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.person_pin_circle_outlined,
                          size: 56,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Completa tu perfil ciudadano',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tu cuenta ya está creada. Completa este paso '
                      'para acceder a tus domicilios y preferencias '
                      'del servicio de recolección.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Con tu perfil podrás',
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            const _PerfilFeature(
                              icon: Icons.home_outlined,
                              text: 'Registrar tus domicilios.',
                            ),
                            const SizedBox(height: 12),
                            const _PerfilFeature(
                              icon: Icons.calendar_month_outlined,
                              text:
                                  'Consultar días y horarios '
                                  'de recolección.',
                            ),
                            const SizedBox(height: 12),
                            const _PerfilFeature(
                              icon: Icons.notifications_outlined,
                              text:
                                  'Configurar tus preferencias '
                                  'de avisos.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Incorporar aquí el texto institucional
                    // o acceso a su política antes de publicar.
                    Text(
                      'Tratamiento de datos personales',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La configuración del domicilio y las alertas '
                      'se realizará después de crear el perfil. '
                      'Este paso no activa el GPS ni concede '
                      'permisos de notificaciones al teléfono.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _aceptaTratamientoDatos,
                      onChanged: widget.isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _aceptaTratamientoDatos = value ?? false;
                              });
                            },
                      title: const Text(
                        'Acepto el tratamiento de mis datos '
                        'personales para el servicio de '
                        'recolección de residuos.',
                      ),
                      subtitle: const Text('Versión $_versionConsentimiento'),
                    ),
                    if (_submitted && !_aceptaTratamientoDatos) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Debes aceptar el tratamiento de datos '
                        'para crear el perfil.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: widget.isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isSaving) ...[
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Flexible(
                            child: Text(
                              widget.isSaving
                                  ? 'Creando perfil…'
                                  : 'Crear mi perfil ciudadano',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PerfilFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PerfilFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
