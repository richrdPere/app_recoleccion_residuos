// *********************************************************
// REQUEST
// *********************************************************
class RegistrarDispositivoRequest {
  final String identificadorDispositivo;
  final String tokenPush;
  final String plataforma;
  final String nombreDispositivo;
  final String modeloDispositivo;
  final String versionSistema;
  final String versionAplicacion;
  final String permisoNotificaciones;

  const RegistrarDispositivoRequest({
    required this.identificadorDispositivo,
    required this.tokenPush,
    required this.plataforma,
    required this.nombreDispositivo,
    required this.modeloDispositivo,
    required this.versionSistema,
    required this.versionAplicacion,
    required this.permisoNotificaciones,
  });

  Map<String, dynamic> toJson() {
    return {
      'identificador_dispositivo': identificadorDispositivo,
      'token_push': tokenPush,
      'plataforma': plataforma,
      'nombre_dispositivo': nombreDispositivo,
      'modelo_dispositivo': modeloDispositivo,
      'version_sistema': versionSistema,
      'version_aplicacion': versionAplicacion,
      'permiso_notificaciones': permisoNotificaciones,
    };
  }
}
