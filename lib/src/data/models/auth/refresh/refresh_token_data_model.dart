class RefreshTokenDataModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String expiresIn;

  const RefreshTokenDataModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory RefreshTokenDataModel.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];

      if (value is! String || value.trim().isEmpty) {
        throw FormatException(
          'La respuesta de renovación no contiene un $key válido.',
        );
      }

      return value.trim();
    }

    return RefreshTokenDataModel(
      accessToken: requiredString('access_token'),
      refreshToken: requiredString('refresh_token'),
      tokenType: requiredString('token_type'),
      expiresIn: requiredString('expires_in'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}
