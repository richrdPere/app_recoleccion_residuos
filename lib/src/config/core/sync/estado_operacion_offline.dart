import 'package:flutter/material.dart';

import 'operacion_offline.dart';

class EstadoOperacionOffline extends StatelessWidget {
  const EstadoOperacionOffline({super.key});

  Future<void> _verPendientes(BuildContext context) async {
    final servicio = OperacionOffline.instance;
    final registros = await servicio.pendientesUsuario();

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * 0.65,

            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Operaciones pendientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: registros.length,

                    itemBuilder: (_, index) {
                      final registro = registros[index];

                      return ListTile(
                        title: Text(
                          '${registro['tipo']} · '
                          'Recorrido ${registro['recorrido']}',
                        ),

                        subtitle: Text(
                          '${registro['estado']}'
                          '${registro['error'] == null ? '' : '\n${registro['error']}'}',
                        ),

                        trailing: IconButton(
                          tooltip: 'Reintentar sin cambiar la clave',

                          icon: const Icon(Icons.refresh),

                          onPressed: () async {
                            Navigator.pop(sheetContext);

                            await servicio.reintentar(
                              (registro['seq'] as num).toInt(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicio = OperacionOffline.instance;

    return ListenableBuilder(
      listenable: servicio,

      builder: (context, _) {
        if (servicio.pendientes == 0 &&
            !servicio.capturando &&
            servicio.mensaje == null) {
          return const SizedBox.shrink();
        }

        return Material(
          color: servicio.bloqueadas > 0
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.secondaryContainer,

          child: SafeArea(
            bottom: false,

            child: ListTile(
              dense: true,

              leading: Icon(
                servicio.capturando
                    ? Icons.location_on
                    : Icons.cloud_upload_outlined,
              ),

              title: Text(
                '${servicio.pendientes} pendientes'
                ' · GPS ${servicio.capturando ? 'activo' : 'detenido'}',
              ),

              subtitle: servicio.mensaje == null
                  ? null
                  : Text(servicio.mensaje!),

              trailing: TextButton(
                onPressed: servicio.pendientes == 0
                    ? null
                    : () => _verPendientes(context),

                child: const Text('Revisar'),
              ),
            ),
          ),
        );
      },
    );
  }
}
