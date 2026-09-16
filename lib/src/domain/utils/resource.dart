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
