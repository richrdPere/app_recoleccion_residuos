import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Widget
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/customs/custom_bottom_navigation.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const List<String> _routes = [
    '/home',
    '/mi-recorrido',
    '/historial',
    '/perfil',
  ];

  // *********************************************************
  // 1. OBTENER OPCIÓN ACTUAL
  // *********************************************************
  int _getCurrentIndex(String location) {
    final index = _routes.indexWhere(
      (route) => location == route || location.startsWith('$route/'),
    );

    return index >= 0 ? index : 0;
  }

  // *********************************************************
  // 2. NAVEGAR
  // *********************************************************
  void _onNavigationTap(BuildContext context, int index, int currentIndex) {
    if (index < 0 || index >= _routes.length) return;

    if (index == currentIndex) return;

    context.go(_routes[index]);
  }

  // *********************************************************
  // 3. INTERFAZ
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          _onNavigationTap(context, index, currentIndex);
        },
      ),
    );
  }
}
