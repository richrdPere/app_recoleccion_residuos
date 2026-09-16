import 'package:app_recoleccion_residuos/src/data/models/auth/datos/usuario_data_model.dart';

class LoginDataModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String expiresIn;
  final String refreshExpiresIn;
  final UsuarioDataModel usuario;

  const LoginDataModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.usuario,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'] as String;
    final refreshToken = json['refresh_token'] as String;

    if (accessToken.trim().isEmpty || refreshToken.trim().isEmpty) {
      throw const FormatException(
        'La respuesta de login contiene tokens vacíos.',
      );
    }

    return LoginDataModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as String,
      refreshExpiresIn: json['refresh_expires_in'] as String,
      usuario: UsuarioDataModel.fromJson(
        Map<String, dynamic>.from(json['usuario'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'refresh_expires_in': refreshExpiresIn,
      'usuario': usuario.toJson(),
    };
  }
}
