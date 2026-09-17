import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_bar_title_screen.dart';
import 'package:flutter/material.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

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

  // *********************************************************
  // 1. INTERFAZ
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final usuario = state.usuario;

    return Scaffold(
      appBar: AppBarTitleScreen(
        title: 'Mi perfil',
        actions: [
          // ACTUALIZAR
          AppBarTitleAction(
            icon: Icons.refresh_rounded,
            tooltip: state.isLoading
                ? 'Actualizando zonas...'
                : 'Actualizar zonas',
            color: state.isLoading ? colors.primary : null,
            onPressed: () async => await onRefresh(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 360
                  ? 16.0
                  : 24.0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // *****************************
                          // ESTADOS DE CONSULTA
                          // *****************************
                          if (usuario == null)
                            _buildWithoutData(context)
                          else ...[
                            if (state.isRefreshing) ...[
                              const LinearProgressIndicator(),
                              const SizedBox(height: 16),
                            ],

                            if (state.hasError) ...[
                              Text(
                                'No se pudo actualizar. Se muestran '
                                'los últimos datos consultados.',
                                style: TextStyle(color: colors.error),
                              ),
                              const SizedBox(height: 16),
                            ],

                            _buildHeader(context, usuario),
                            const SizedBox(height: 20),

                            _buildPersonalInformation(usuario),
                            const SizedBox(height: 20),

                            _buildAccountInformation(usuario),
                          ],

                          const SizedBox(height: 28),

                          // *****************************
                          // CIERRE DE SESIÓN
                          // *****************************
                          OutlinedButton.icon(
                            onPressed: onLogout,
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Cerrar sesión'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.error,
                              minimumSize: const Size(double.infinity, 52),
                              side: BorderSide(color: colors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // *********************************************************
  // 2. CARGA O ERROR INICIAL
  // *********************************************************
  Widget _buildWithoutData(BuildContext context) {
    final theme = Theme.of(context);

    final isLoading = state.status == PerfilStatus.initial || state.isBusy;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 72),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Consultando tu perfil…'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 56,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'No se pudo cargar tu perfil',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            state.errorMessage ?? 'No se encontraron los datos de tu perfil.',
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
      ),
    );
  }

  // *********************************************************
  // 3. FOTO, NOMBRE Y ROLES
  // *********************************************************
  Widget _buildHeader(BuildContext context, UsuarioDataModel usuario) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nombre = usuario.nombreCompleto.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _PerfilAvatar(fotoUrl: usuario.persona.fotoUrl),
            const SizedBox(height: 16),
            Text(
              nombre.isEmpty ? usuario.username : nombre,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            if (usuario.roles.isEmpty)
              const Text('Sin roles asignados')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: usuario.roles.map((rol) {
                  return Chip(
                    avatar: const Icon(Icons.verified_user_outlined, size: 18),
                    label: Text(rol.nombre),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // *********************************************************
  // 4. INFORMACIÓN PERSONAL
  // *********************************************************
  Widget _buildPersonalInformation(UsuarioDataModel usuario) {
    final persona = usuario.persona;

    return _PerfilSection(
      title: 'Información personal',
      children: [
        _PerfilField(
          icon: Icons.badge_outlined,
          label: persona.tipoDocumento,
          value: persona.numeroDocumento,
        ),
        _PerfilField(
          icon: Icons.cake_outlined,
          label: 'Fecha de nacimiento',
          value: _formatBirthDate(persona.fechaNacimiento),
        ),
        _PerfilField(
          icon: Icons.phone_outlined,
          label: 'Celular',
          value: _displayValue(persona.celular),
        ),
        _PerfilField(
          icon: Icons.location_on_outlined,
          label: 'Dirección',
          value: _displayValue(persona.direccion),
        ),
        _PerfilField(
          icon: Icons.person_outline_rounded,
          label: 'Género',
          value: _formatGender(persona.genero),
        ),
      ],
    );
  }

  // *********************************************************
  // 5. INFORMACIÓN DE LA CUENTA
  // *********************************************************
  Widget _buildAccountInformation(UsuarioDataModel usuario) {
    return _PerfilSection(
      title: 'Información de la cuenta',
      children: [
        _PerfilField(
          icon: Icons.alternate_email_rounded,
          label: 'Usuario',
          value: usuario.username,
        ),
        _PerfilField(
          icon: Icons.email_outlined,
          label: 'Correo de acceso',
          value: _displayValue(usuario.emailAcceso),
        ),
        _PerfilField(
          icon: Icons.manage_accounts_outlined,
          label: 'Estado de la cuenta',
          value: usuario.estado ? 'Activa' : 'Inactiva',
        ),
        _PerfilField(
          icon: Icons.access_time_rounded,
          label: 'Último acceso',
          value: _formatDateTime(usuario.ultimoAcceso),
        ),
        _PerfilField(
          icon: Icons.calendar_today_outlined,
          label: 'Fecha de registro',
          value: _formatDateTime(usuario.createdAt),
        ),
      ],
    );
  }

  // *********************************************************
  // 6. FORMATOS
  // *********************************************************
  String _displayValue(String? value) {
    final normalized = value?.trim();

    return normalized == null || normalized.isEmpty
        ? 'No registrado'
        : normalized;
  }

  String _formatGender(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'M':
        return 'Masculino';
      case 'F':
        return 'Femenino';
      default:
        return _displayValue(value);
    }
  }

  String _formatBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No registrada';
    }

    final date = DateTime.tryParse(value);

    if (date == null) return 'No disponible';

    // Es una fecha sin hora: no convertir a zona local.
    return '${_twoDigits(date.day)}/'
        '${_twoDigits(date.month)}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'No registrado';

    final local = value.toLocal();

    return '${_twoDigits(local.day)}/'
        '${_twoDigits(local.month)}/'
        '${local.year} '
        '${_twoDigits(local.hour)}:'
        '${_twoDigits(local.minute)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

// ***********************************************************
// AVATAR CON RESPALDO SI NO EXISTE FOTO O FALLA SU CARGA
// ***********************************************************
class _PerfilAvatar extends StatelessWidget {
  final String? fotoUrl;

  const _PerfilAvatar({required this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = fotoUrl?.trim();
    final uri = url == null ? null : Uri.tryParse(url);

    final hasValidUrl =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    final fallback = ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 52,
          color: colors.onPrimaryContainer,
        ),
      ),
    );

    return SizedBox(
      width: 96,
      height: 96,
      child: ClipOval(
        child: hasValidUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}

// ***********************************************************
// SECCIÓN DE DATOS
// ***********************************************************
class _PerfilSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PerfilSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const Divider(height: 1),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}

// ***********************************************************
// CAMPO DE INFORMACIÓN
// ***********************************************************
class _PerfilField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PerfilField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
