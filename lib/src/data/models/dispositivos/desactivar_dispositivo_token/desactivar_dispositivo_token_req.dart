// *********************************************************
// REQUEST
// *********************************************************
class DesactivarDispositivoTokenRequest {
  final String tokenPush;

  const DesactivarDispositivoTokenRequest({required this.tokenPush});

  Map<String, dynamic> toJson() {
    return {'token_push': tokenPush};
  }
}
