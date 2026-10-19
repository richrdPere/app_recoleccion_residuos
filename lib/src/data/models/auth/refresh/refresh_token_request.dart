class RefreshTokenRequest {
  final String refreshToken;
  final String dispositivo;

  const RefreshTokenRequest({
    required this.refreshToken,
    this.dispositivo = 'APP_MOVIL',
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
      'dispositivo': dispositivo,
    };
  }
}