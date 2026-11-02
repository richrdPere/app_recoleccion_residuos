import 'package:flutter/material.dart';

// Widgets
import 'package:app_recoleccion_residuos/src/presentation/screens/notificaciones/view/widgets/notifications_bell.dart';

class MapaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onVolver;

  const MapaAppBar({super.key, this.onVolver});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
        child: IconButton(
          tooltip: 'Volver al inicio',
          onPressed: onVolver,
          style: IconButton.styleFrom(
            backgroundColor: colors.surface.withValues(alpha: 0.95),
            foregroundColor: colors.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      titleSpacing: 8,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Mi recorrido',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          child: Material(
            color: colors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(15),
            child: const NotificationsBell(),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
