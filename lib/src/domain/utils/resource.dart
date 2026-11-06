abstract class Resource<T> {}

class Initial<T> extends Resource<T> {}

class Loading<T> extends Resource<T> {}

class Success<T> extends Resource<T> {
  final T data;
  Success(this.data);
}

class ErrorData<T> extends Resource<T> {
  final String message;
  final String? error;
  final int? statusCode;

  ErrorData({required this.message, this.error, this.statusCode});

  String get fullMessage {
    if (error == null || error!.isEmpty) return message;
    return '$message $error';
  }

  @override
  String toString() => fullMessage;
}

class PendingOperation<T> extends Resource<T> {
  final String clave;
  final String message;

  /// Puede contener una proyección local.
  /// No representa una confirmación del servidor.
  final T? data;

  PendingOperation({required this.clave, required this.message, this.data});
}

// Success(...)          // Confirmado o consultado.
// PendingOperation(...) // Guardado localmente; falta sincronizar.
// ErrorData(...)        // No se pudo completar.
