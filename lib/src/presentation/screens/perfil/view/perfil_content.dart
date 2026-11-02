import 'package:flutter/material.dart';

import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/presentation/screens/perfil/bloc/perfil_state.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar_title_screen.dart';

class PerfilContent extends StatelessWidget {
  final PerfilState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;

  const PerfilContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final usuario = state.usuario;

    final fondo = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.04),
      colors.surface,
    );

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBarTitleScreen(
        title: 'Mi perfil',
        backgroundColor: fondo,
        actions: [
          AppBarTitleAction(
            icon: Icons.refresh_rounded,
            tooltip: state.isBusy
                ? 'Actualizando perfil...'
                : 'Actualizar perfil',
            color: state.isBusy ? colors.primary : null,
            onPressed: state.isBusy
                ? null
                : () async {
                    await onRefresh();
                  },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.isBusy) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const LinearProgressIndicator(minHeight: 3),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (usuario == null)
                        _sinDatos(context)
                      else ...[
                        if (state.hasError) ...[
                          _PerfilSuperficie(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: colors.error,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'No se pudo actualizar. Se muestran '
                                    'los últimos datos consultados.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        _cabecera(context, usuario),

                        const SizedBox(height: 28),

                        _titulo(
                          context,
                          'Información personal',
                          'Tus datos registrados',
                        ),

                        const SizedBox(height: 12),

                        _PerfilSuperficie(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _PerfilDato(
                                icono: Icons.badge_outlined,
                                titulo: usuario.persona.tipoDocumento,
                                valor: _texto(usuario.persona.numeroDocumento),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.phone_outlined,
                                titulo: 'Celular',
                                valor: _texto(usuario.persona.celular),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.location_on_outlined,
                                titulo: 'Dirección',
                                valor: _texto(usuario.persona.direccion),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.cake_outlined,
                                titulo: 'Fecha de nacimiento',
                                valor: _fechaNacimiento(
                                  usuario.persona.fechaNacimiento,
                                ),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.person_outline_rounded,
                                titulo: 'Género',
                                valor: _genero(usuario.persona.genero),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        _titulo(context, 'Mi cuenta', 'Información de acceso'),

                        const SizedBox(height: 12),

                        _PerfilSuperficie(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _PerfilDato(
                                icono: Icons.alternate_email_rounded,
                                titulo: 'Usuario',
                                valor: _texto(usuario.username),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.mail_outline_rounded,
                                titulo: 'Correo de acceso',
                                valor: _texto(usuario.emailAcceso),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.verified_user_outlined,
                                titulo: 'Estado de la cuenta',
                                valor: usuario.estado ? 'Activa' : 'Inactiva',
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.access_time_rounded,
                                titulo: 'Último acceso',
                                valor: _fechaHora(usuario.ultimoAcceso),
                              ),
                              const _PerfilSeparador(),
                              _PerfilDato(
                                icono: Icons.calendar_today_outlined,
                                titulo: 'Fecha de registro',
                                valor: _fechaHora(usuario.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      FilledButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Cerrar sesión'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.errorContainer,
                          foregroundColor: colors.onErrorContainer,
                          minimumSize: const Size(double.infinity, 54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // *********************************************************
  // CABECERA: AVATAR, NOMBRE Y ROLES
  // *********************************************************

  Widget _cabecera(BuildContext context, UsuarioDataModel usuario) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final nombre = usuario.nombreCompleto.trim();
    final nombreVisible = nombre.isEmpty ? usuario.username : nombre;

    return _PerfilSuperficie(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          _PerfilAvatar(fotoUrl: usuario.persona.fotoUrl),

          const SizedBox(height: 18),

          Text(
            nombreVisible,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '@${usuario.username}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 18),

          if (usuario.roles.isEmpty)
            Text('Sin roles asignados', style: theme.textTheme.bodySmall)
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final rol in usuario.roles)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rol.nombre.replaceAll('_', ' '),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 22),

          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                usuario.estado
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                size: 18,
                color: usuario.estado ? colors.primary : colors.error,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  usuario.estado ? 'Cuenta activa' : 'Cuenta inactiva',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _titulo(BuildContext context, String titulo, String subtitulo) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // *********************************************************
  // CARGA Y ERROR INICIAL
  // *********************************************************

  Widget _sinDatos(BuildContext context) {
    final theme = Theme.of(context);

    final cargando = state.status == PerfilStatus.initial || state.isBusy;

    return _PerfilSuperficie(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            if (cargando) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Consultando tu perfil...'),
            ] else ...[
              Icon(
                Icons.person_off_outlined,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'No se pudo cargar tu perfil',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ??
                    'No se encontraron los datos de tu perfil.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  await onRefresh();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // FORMATOS
  // *********************************************************

  String _texto(String? valor) {
    final texto = valor?.trim();

    return texto == null || texto.isEmpty ? 'No registrado' : texto;
  }

  String _genero(String? valor) {
    return switch (valor?.trim().toUpperCase()) {
      'M' => 'Masculino',
      'F' => 'Femenino',
      _ => _texto(valor),
    };
  }

  String _fechaNacimiento(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'No registrada';
    }

    final fecha = DateTime.tryParse(valor);
    if (fecha == null) return 'No disponible';

    // Fecha de calendario, sin conversión de zona horaria.
    return '${_dos(fecha.day)}/${_dos(fecha.month)}/${fecha.year}';
  }

  String _fechaHora(DateTime? valor) {
    if (valor == null) return 'No registrado';

    final fecha = valor.toLocal();

    return '${_dos(fecha.day)}/${_dos(fecha.month)}/${fecha.year}'
        ' · ${_dos(fecha.hour)}:${_dos(fecha.minute)}';
  }

  String _dos(int valor) => valor.toString().padLeft(2, '0');
}

// *********************************************************
// SUPERFICIE CON BORDES AMPLIOS Y SOMBRA SUAVE
// *********************************************************

class _PerfilSuperficie extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PerfilSuperficie({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// *********************************************************
// AVATAR CON RESPALDO
// *********************************************************

class _PerfilAvatar extends StatelessWidget {
  final String? fotoUrl;

  const _PerfilAvatar({required this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = fotoUrl?.trim();
    final uri = url == null ? null : Uri.tryParse(url);

    final urlValida =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    final respaldo = ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 52,
          color: colors.onPrimaryContainer,
        ),
      ),
    );

    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.08),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: ClipOval(
        child: urlValida
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progreso) {
                  return progreso == null ? child : respaldo;
                },
                errorBuilder: (_, __, ___) => respaldo,
              )
            : respaldo,
      ),
    );
  }
}

// *********************************************************
// FILA DE INFORMACIÓN
// *********************************************************

class _PerfilDato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _PerfilDato({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, size: 21, color: colors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilSeparador extends StatelessWidget {
  const _PerfilSeparador();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 74, right: 18),
      child: Divider(
        height: 1,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }
}
