class ApiResponse<T> {
  final bool success;
  final String message;

  /// Solo existe normalmente cuando success == true
  final T? data;

  /// Solo existe normalmente cuando success == false
  final String? error;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final rawData = json['data'];

    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString().trim() ?? '',
      data: rawData != null && fromJsonT != null ? fromJsonT(rawData) : null,
      error: json['error']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson({dynamic Function(T data)? toJsonT}) {
    return {
      'success': success,
      'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data as T) : data,
      if (error != null) 'error': error,
    };
  }
}
