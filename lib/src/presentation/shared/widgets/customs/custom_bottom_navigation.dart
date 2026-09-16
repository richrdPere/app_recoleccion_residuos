import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        backgroundColor: colors.surface,
        indicatorColor: colors.secondaryContainer,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Mi recorrido',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_alerta_icon_badge.dart';

// class CustomBottomNavigation extends StatelessWidget {
//   final int currentIndex;
//   final int alertasNoLeidas;
//   final Function(int) onTap;

//   const CustomBottomNavigation({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     this.alertasNoLeidas = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       type: BottomNavigationBarType.fixed,
//       elevation: 5,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       items: [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
//         BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.add_circle, size: 35), // 🔥 más grande
//           label: 'Reporte',
//         ),
//         // BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.edit_document),
//           label: 'Ocurrencias',
//         ),
//         BottomNavigationBarItem(
//           // icon: Icon(Icons.notifications),
//           icon: AppAlertaIconBadge(
//             cantidad: alertasNoLeidas,
//             seleccionado: currentIndex == 4,
//             // iconColor: Colors.grey
//           ),
//           label: 'Alertas',
//         ),
//       ],
//     );
//   }
// }
