import 'package:flutter/material.dart';

class AppAlertaIconBadge extends StatelessWidget {
  final int cantidad;
  final Color iconColor;
  final double iconSize;
  final bool seleccionado;

  const AppAlertaIconBadge({
    super.key,
    required this.cantidad,
    required this.seleccionado,
    this.iconColor = Colors.grey,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarBadge = cantidad > 0;

    final colorIcono = seleccionado ? Colors.blue : iconColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          seleccionado ? Icons.notifications : Icons.notifications_outlined,
          size: iconSize,
          color: colorIcono,
        ),

        if (mostrarBadge)
          Positioned(
            top: -5,
            right: -7,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: cantidad > 1
                  ? Text(
                      cantidad > 99 ? '99+' : '$cantidad',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    )
                  : const SizedBox(width: 5, height: 5),
            ),
          ),
      ],
    );
  }
}
