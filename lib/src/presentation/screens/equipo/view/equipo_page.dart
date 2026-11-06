import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

import 'package:app_recoleccion_residuos/src/config/core/sync/operacion_offline.dart';
import 'package:app_recoleccion_residuos/src/data/models/models.dart';
import 'package:app_recoleccion_residuos/src/domain/utils/resource.dart';

class EquipoPage extends StatefulWidget {
  const EquipoPage({super.key});

  @override
  State<EquipoPage> createState() => _EquipoPageState();
}

class _EquipoPageState extends State<EquipoPage> {
  final servicio = OperacionOffline.instance;

  final cantidad = TextEditingController();
  final observacion = TextEditingController();

  final form = GlobalKey<FormState>();

  List<Map<String, dynamic>> recorridos = [];
  List<Map<String, dynamic>> puntos = [];

  List<Map<String, Object?>> locales = [];

  Map<String, dynamic>? resultado;

  int? seleccionado;

  String unidad = 'KG';
  String aviso = '';

  bool ocupado = false;
  bool sincronizando = false;

  Map<String, dynamic> mapa(Object? value) =>
      Map<String, dynamic>.from(value as Map);

  Map<String, dynamic>? get recorrido {
    for (final item in recorridos) {
      if (item['id_recorrido'] == seleccionado) {
        return item;
      }
    }

    return null;
  }

  bool get tieneResultadoLocal =>
      locales.any((registro) => registro['tipo'] == 'resultado-final');

  @override
  void initState() {
    super.initState();

    servicio.addListener(actualizarCola);
    cargar();
  }

  void actualizarCola() async {
    final termino = sincronizando && !servicio.sincronizando;

    sincronizando = servicio.sincronizando;

    final id = seleccionado;

    if (!termino || id == null) return;

    final filas = await servicio.registrosEquipo(id);

    if (mounted && seleccionado == id) {
      setState(() => locales = filas);
    }
  }

  Future<void> cargar() async {
    if (ocupado) return;

    setState(() {
      ocupado = true;
      aviso = '';
    });

    try {
      final items = await servicio.recorridosEquipo();

      if (!mounted) return;

      if (!items.any((item) => item['id_recorrido'] == seleccionado)) {
        seleccionado = items.isEmpty
            ? null
            : (items.first['id_recorrido'] as num).toInt();
      }

      recorridos = items;
      puntos = [];
      locales = [];
      resultado = null;

      final id = seleccionado;

      if (id != null) {
        locales = await servicio.registrosEquipo(id);

        try {
          final body = await servicio.consultar(
            '/recorridos/$id/resultado-final',
          );

          final dato = mapa(body['data'])['resultado_final'];

          resultado = dato == null ? null : mapa(dato);
        } catch (_) {
          aviso =
              'Resultado remoto sin verificar; '
              'se conservan los registros locales.';
        }

        try {
          final body = await servicio.consultar(
            '/recolecciones/recorridos/$id/puntos',
          );

          puntos = (body['data'] as List).map(mapa).toList();
        } catch (_) {
          aviso =
              'No hay puntos disponibles. Consúltalos '
              'con conexión antes de salir.';
        }

        // Distinguir atención local de confirmación remota.
        for (final fila in locales.where(
          (registro) =>
              registro['tipo'] == 'recoleccion' &&
              registro['estado'] != 'enviado',
        )) {
          final dato = mapa(jsonDecode(fila['payload'] as String));

          for (final punto in puntos) {
            if (punto['id_ruta_punto'] == dato['id_ruta_punto']) {
              punto['estado_atencion'] = fila['estado'] == 'bloqueado'
                  ? 'REVISAR SINCRONIZACIÓN'
                  : 'ATENDIDO · PENDIENTE';
            }
          }
        }
      }
    } catch (error) {
      aviso = '$error';
    } finally {
      if (mounted) {
        setState(() => ocupado = false);
      }
    }
  }

  Future<void> atender(Map<String, dynamic> punto) async {
    if (ocupado || seleccionado == null) return;

    final id = seleccionado!;

    setState(() => ocupado = true);

    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) {
        throw StateError('Activa el GPS.');
      }

      var permiso = await geo.Geolocator.checkPermission();

      if (permiso == geo.LocationPermission.denied) {
        permiso = await geo.Geolocator.requestPermission();
      }

      if (![
        geo.LocationPermission.whileInUse,
        geo.LocationPermission.always,
      ].contains(permiso)) {
        throw StateError(
          'Concede permiso de ubicación '
          'para registrar el punto.',
        );
      }

      final posicion = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      if (posicion.isMocked ||
          DateTime.now().difference(posicion.timestamp).inSeconds.abs() > 120) {
        throw StateError('No se obtuvo una ubicación reciente válida.');
      }

      final respuesta = await servicio
          .guardar<Map<String, dynamic>>('recoleccion', {
            'id_recorrido': id,
            'id_ruta_punto': punto['id_ruta_punto'],

            'fecha_dispositivo': DateTime.now().toUtc().toIso8601String(),

            'latitud': posicion.latitude,
            'longitud': posicion.longitude,
            'precision_gps': posicion.accuracy,
          });

      if (respuesta is ErrorData<ApiResponse<Map<String, dynamic>>>) {
        throw StateError(respuesta.message);
      }

      aviso =
          'Atención guardada en el dispositivo. '
          'Revisa el estado de sincronización.';
    } catch (error) {
      aviso = '$error';
    } finally {
      if (mounted) {
        setState(() => ocupado = false);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aviso)));
    }

    await cargar();
  }

  Future<void> guardar() async {
    if (ocupado || seleccionado == null || !form.currentState!.validate()) {
      return;
    }

    final id = seleccionado!;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar resultado final'),

        content: Text(
          '¿Terminó físicamente el recorrido #$id?\n'
          'Registrarás ${cantidad.text} $unidad '
          'como total del recorrido. '
          'Una vez guardado no podrás sobrescribirlo '
          'desde este formulario.',
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),

          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmado != true) return;

    setState(() => ocupado = true);

    try {
      final respuesta = await servicio.guardarResultadoFinal(id, {
        'cantidad_total': double.parse(
          cantidad.text.trim().replaceAll(',', '.'),
        ),

        'unidad_medida': unidad,
        'observacion': observacion.text.trim(),

        'fecha_dispositivo': DateTime.now().toUtc().toIso8601String(),
      });

      if (respuesta is ErrorData<ApiResponse<Map<String, dynamic>>>) {
        throw StateError(respuesta.message);
      }

      aviso = (respuesta as PendingOperation<ApiResponse<Map<String, dynamic>>>)
          .message;
    } catch (error) {
      aviso = '$error';
    } finally {
      if (mounted) {
        setState(() => ocupado = false);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aviso)));
    }

    await cargar();
  }

  @override
  Widget build(BuildContext context) {
    final estado = recorrido?['estado_recorrido'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trabajo del equipo'),

        actions: [
          IconButton(
            onPressed: ocupado ? null : cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          if (ocupado) const LinearProgressIndicator(),

          if (aviso.isNotEmpty) Text(aviso),

          if (recorridos.isEmpty)
            const Text(
              'No hay recorridos guardados. '
              'Consulta tus asignaciones con conexión.',
            ),

          DropdownButtonFormField<int>(
            value: seleccionado,

            decoration: const InputDecoration(
              labelText: 'Recorrido del equipo',
            ),

            items: recorridos.map((item) {
              return DropdownMenuItem<int>(
                value: (item['id_recorrido'] as num).toInt(),

                child: Text(
                  '#${item['id_recorrido']} · '
                  '${item['estado_recorrido']}',
                ),
              );
            }).toList(),

            onChanged: ocupado
                ? null
                : (value) {
                    setState(() {
                      seleccionado = value;
                      cantidad.clear();
                      observacion.clear();
                    });

                    cargar();
                  },
          ),

          const SizedBox(height: 20),

          const Text(
            'Atención de puntos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const Text('La atención no registra peso ni volumen.'),

          for (final punto in puntos.where(
            (item) => item['tipo_punto'] == 'RECOLECCION',
          ))
            ListTile(
              contentPadding: EdgeInsets.zero,

              title: Text('${punto['nombre']}'),

              subtitle: Text('${punto['estado_atencion']}'),

              trailing: TextButton(
                onPressed:
                    !ocupado &&
                        estado == 'EN_CURSO' &&
                        !tieneResultadoLocal &&
                        punto['estado_atencion'] == 'PENDIENTE'
                    ? () => atender(punto)
                    : null,

                child: const Text('Atendido'),
              ),
            ),

          const Divider(height: 32),

          const Text(
            'Resultado final de residuos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const Text(
            'Un total por recorrido. Si falta el cierre '
            'del conductor, el envío esperará automáticamente.',
          ),

          if (resultado != null) ...[
            Text(
              'Confirmado: '
              '${resultado!['cantidad_total']} '
              '${resultado!['unidad_medida']}',
            ),

            Text(
              resultado!['capacidad'] == null
                  ? 'Capacidad final no calculable '
                        'con la unidad registrada.'
                  : 'Carga final: '
                        '${mapa(resultado!['capacidad'])['porcentaje']} %',
            ),
          ] else if (tieneResultadoLocal) ...[
            for (final registro in locales.where(
              (item) => item['tipo'] == 'resultado-final',
            ))
              ListTile(
                title: Text('Resultado: ${registro['estado']}'),

                subtitle: Text(
                  '${mapa(jsonDecode(registro['payload'] as String))['cantidad_total']} '
                  '${mapa(jsonDecode(registro['payload'] as String))['unidad_medida']}'
                  '${registro['error'] == null ? '' : '\n${registro['error']}'}',
                ),
              ),
          ] else
            Form(
              key: form,

              child: Column(
                children: [
                  TextFormField(
                    controller: cantidad,
                    enabled: !ocupado,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Cantidad total de residuos',
                    ),

                    validator: (value) {
                      final texto = (value ?? '').trim().replaceAll(',', '.');

                      final numero = double.tryParse(texto);

                      if (numero == null ||
                          !numero.isFinite ||
                          numero < 0 ||
                          numero > 99999999999.999 ||
                          !RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(texto)) {
                        return 'Ingresa una cantidad válida, '
                            'con hasta tres decimales.';
                      }

                      return null;
                    },
                  ),

                  DropdownButtonFormField<String>(
                    value: unidad,

                    decoration: const InputDecoration(labelText: 'Unidad'),

                    items: ['KG', 'TONELADA', 'LITRO', 'M3'].map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),

                    onChanged: ocupado
                        ? null
                        : (value) {
                            setState(() => unidad = value!);
                          },
                  ),

                  TextFormField(
                    controller: observacion,
                    enabled: !ocupado,
                    maxLength: 1000,

                    decoration: const InputDecoration(
                      labelText: 'Observación del resultado',
                    ),
                  ),

                  FilledButton(
                    onPressed: ocupado || seleccionado == null ? null : guardar,

                    child: const Text('Guardar resultado final'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    servicio.removeListener(actualizarCola);

    cantidad.dispose();
    observacion.dispose();

    super.dispose();
  }
}
