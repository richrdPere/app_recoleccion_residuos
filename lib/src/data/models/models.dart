// =======================================================
// COMMON
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/common/api_response.dart';

// =======================================================
// AUTH
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/auth/login/login_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/auth/login/login_request.dart';
export 'package:app_recoleccion_residuos/src/data/models/auth/logout/logout_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/auth/logout/logout_request.dart';
export 'package:app_recoleccion_residuos/src/data/models/auth/datos/usuario_data_model.dart';

// =======================================================
// RECORRIDOS
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/recorrido/datos/recorrido_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recorrido/finalizar_recorrido/finalizar_recorrido_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/recorrido/iniciar_recorrido/iniciar_recorrido_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/recorrido/mis-recorridos/mis_recorridos_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recorrido/pausar_recorrido/pausar_recorrido_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/recorrido/reanudar_recorrido/reanudar_recorrido_req.dart';

// =======================================================
// RECOLECCION
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/capacidad/capacidad_recorrido_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/detalle/recoleccion_detalle_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/evidencias/recoleccion_evidencia_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/evidencias/registrar_evidencia_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/progreso_recorrido/recorrido_progreso_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/puntos_recorrido/punto_recorrido_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion/registrar_recoleccion_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion_lote/registrar_recoleccion_lote_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/recolecciones/registrar_recoleccion_lote/registrar_recoleccion_lote_req.dart';

// =======================================================
// TRACKING
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/tracking/registrar_ubicacion/registrar_ubicacion_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/tracking/registrar_ubicacion/registrar_ubicacion_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/tracking/registrar_ubicacion_lote/registrar_ubicacion_lote_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/tracking/registrar_ubicacion_lote/registrar_ubicacion_lote_req.dart';

// =======================================================
// NOTIFICACIONES
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/archivar_notificacion_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/get_mis_notificaciones_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/get_mis_notificaciones_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/get_notificacion_by_id_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/get_total_no_leidas_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/marcar_notificacion_leida_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/notificaciones/marcar_todas_notificaciones_leidas_data_model.dart';

// =======================================================
// DISPOSITIVOS
// =======================================================
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/desactivar_dispositivo/desactivar_dispositivo_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/desactivar_dispositivo/desactivar_dispositivo_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/desactivar_dispositivo_token/desactivar_dispositivo_token_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/desactivar_dispositivo_token/desactivar_dispositivo_token_req.dart';
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/get_mis%20dispositivo/get_mis_dispositivos_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/registrar_dispositivo/registrar_dispositivo_data_model.dart';
export 'package:app_recoleccion_residuos/src/data/models/dispositivos/registrar_dispositivo/registrar_dispositivo_req.dart';
