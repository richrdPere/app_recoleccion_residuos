import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar_title_screen.dart';

class CiudadanoCuentaContent extends StatelessWidget {
  final CiudadanoCuentaState state;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final bool canLogout;
  final VoidCallback onEdit;
  final VoidCallback onOpenDomicilios;

  const CiudadanoCuentaContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLogout,
    required this.canLogout,
    required this.onEdit,
    required this.onOpenDomicilios,
  });

  String _display(String? value) {
    final text = value?.trim();

    return text == null || text.isEmpty ? 'No registrado' : text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final perfil = state.perfil;

    final canEdit =
        perfil != null && state.status == CiudadanoCuentaStatus.ready;

    return Scaffold(
      appBar: AppBarTitleScreen(
        title: 'Mi cuenta',
        automaticallyImplyLeading: false,
        actions: [
          AppBarTitleAction(
            icon: Icons.edit_outlined,
            tooltip: 'Editar perfil ciudadano',
            onPressed: canEdit ? onEdit : null,
          ),
          AppBarTitleAction(
            icon: Icons.refresh_rounded,
            tooltip: state.isBusy
                ? 'Actualizando cuenta…'
                : 'Actualizar cuenta',
            color: state.isBusy ? colors.primary : null,
            onPressed: state.isBusy ? null : onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.isBusy) const LinearProgressIndicator(),

            Expanded(
              child: Builder(
                builder: (context) {
                  // *************************************
                  // SIN PERFIL CARGADO
                  // *************************************

                  if (perfil == null) {
                    if (state.isBusy ||
                        state.status == CiudadanoCuentaStatus.initial ||
                        state.needsProfile) {
                      return const Center(
                        child: Text('Consultando tu cuenta…'),
                      );
                    }

                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: colors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage ??
                                  'No se pudo cargar tu cuenta.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: onRefresh,
                              child: const Text('Reintentar'),
                            ),
                            TextButton(
                              onPressed: canLogout ? onLogout : null,
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final persona = perfil.usuario.persona;
                  final preferencias = perfil.preferenciasNotificacion;

                  final foto = persona.fotoUrl?.trim();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.isFailure) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors.errorContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  state.errorMessage ??
                                      'No se pudo actualizar '
                                          'la información.',
                                  style: TextStyle(
                                    color: colors.onErrorContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // *********************************
                            // FOTO Y FRANJA DE RESUMEN
                            // *********************************
                            SizedBox(
                              height: 150,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Positioned(
                                    top: 72,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 78,
                                      decoration: BoxDecoration(
                                        color: colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _CuentaStat(
                                              value:
                                                  '${perfil.domicilios.length}',
                                              label: 'Domicilios',
                                            ),
                                          ),
                                          const SizedBox(width: 110),
                                          Expanded(
                                            child: _CuentaStat(
                                              value:
                                                  perfil.estadoCiudadano ==
                                                      'ACTIVO'
                                                  ? 'Activo'
                                                  : perfil.estadoCiudadano,
                                              label: 'Perfil',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: foto != null && foto.isNotEmpty
                                            ? Image.network(
                                                foto,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) {
                                                      return const _AvatarFallback();
                                                    },
                                              )
                                            : const _AvatarFallback(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // *********************************
                            // IDENTIDAD
                            // *********************************
                            Text(
                              persona.nombreCompleto,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              perfil.usuario.emailAcceso,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Calca · Perfil ciudadano',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // *********************************
                            // MIS DOMICILIOS
                            // *********************************
                            _CuentaMenuTile(
                              icon: Icons.home_outlined,
                              title: 'Mis domicilios',
                              subtitle: 'Administra tus direcciones',
                              onTap: state.isBusy ? null : onOpenDomicilios,
                            ),
                            const Divider(height: 1),

                            // *********************************
                            // DATOS PERSONALES
                            // *********************************
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.only(
                                bottom: 16,
                              ),
                              leading: Icon(
                                Icons.person_outline_rounded,
                                color: colors.primary,
                              ),
                              title: const Text('Datos personales'),
                              children: [
                                _CuentaInfo(
                                  label: persona.tipoDocumento,
                                  value: persona.numeroDocumento,
                                ),
                                _CuentaInfo(
                                  label: 'Usuario',
                                  value: perfil.usuario.username,
                                ),
                                _CuentaInfo(
                                  label: 'Correo de contacto',
                                  value: _display(persona.emailContacto),
                                ),
                                _CuentaInfo(
                                  label: 'Celular',
                                  value: _display(persona.celular),
                                ),
                                _CuentaInfo(
                                  label: 'Verificación del celular',
                                  value: perfil.celularVerificado
                                      ? 'Verificado'
                                      : 'Sin verificar',
                                ),
                              ],
                            ),
                            const Divider(height: 1),

                            // *********************************
                            // RESUMEN DE NOTIFICACIONES
                            // *********************************
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.only(
                                bottom: 16,
                              ),
                              leading: Icon(
                                Icons.notifications_outlined,
                                color: colors.primary,
                              ),
                              title: const Text('Notificaciones'),
                              children: [
                                _CuentaInfo(
                                  label: 'Preferencias',
                                  value: preferencias == null
                                      ? 'No disponibles'
                                      : preferencias.notificacionesHabilitadas
                                      ? 'Habilitadas'
                                      : 'Deshabilitadas',
                                ),
                                if (preferencias != null) ...[
                                  _CuentaInfo(
                                    label: 'Canal push',
                                    value: preferencias.canalPush
                                        ? 'Habilitado'
                                        : 'Deshabilitado',
                                  ),
                                  _CuentaInfo(
                                    label: 'Avisos de aproximación',
                                    value:
                                        preferencias.notificarProximidadVehiculo
                                        ? 'Habilitados'
                                        : 'Deshabilitados',
                                  ),
                                ],
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    'La recepción de avisos push '
                                    'también depende de los permisos '
                                    'y del dispositivo registrado.',
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),

                            // *********************************
                            // CONSENTIMIENTO
                            // *********************************
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.only(
                                bottom: 16,
                              ),
                              leading: Icon(
                                Icons.privacy_tip_outlined,
                                color: colors.primary,
                              ),
                              title: const Text('Privacidad y consentimiento'),
                              children: [
                                _CuentaInfo(
                                  label: 'Tratamiento de datos',
                                  value: perfil.aceptaTratamientoDatos
                                      ? 'Aceptado'
                                      : 'No aceptado',
                                ),
                                _CuentaInfo(
                                  label: 'Versión del consentimiento',
                                  value: _display(perfil.versionConsentimiento),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: canEdit ? onEdit : null,
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text(
                                      'Editar perfil ciudadano',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1),

                            // *********************************
                            // CERRAR SESIÓN
                            // *********************************
                            _CuentaMenuTile(
                              icon: Icons.logout_rounded,
                              title: 'Cerrar sesión',
                              color: colors.error,
                              onTap: canLogout ? onLogout : null,
                            ),
                            const SizedBox(height: 32),

                            Text(
                              'Municipalidad Provincial de Calca',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// *********************************************************
// AVATAR SIN FOTO
// *********************************************************

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.secondaryContainer,
      child: Icon(
        Icons.person_rounded,
        size: 64,
        color: colors.onSecondaryContainer,
      ),
    );
  }
}

// *********************************************************
// RESUMEN DEL ENCABEZADO
// *********************************************************

class _CuentaStat extends StatelessWidget {
  final String value;
  final String label;

  const _CuentaStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

// *********************************************************
// OPCIÓN DEL MENÚ
// *********************************************************

class _CuentaMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const _CuentaMenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      enabled: onTap != null,
      leading: Icon(icon),
      iconColor: color ?? Theme.of(context).colorScheme.primary,
      textColor: color,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

// *********************************************************
// DATO DESPLEGABLE
// *********************************************************

class _CuentaInfo extends StatelessWidget {
  final String label;
  final String value;

  const _CuentaInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(dense: true, title: Text(label), subtitle: Text(value));
  }
}
