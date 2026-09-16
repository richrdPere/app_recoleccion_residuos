class LogoutDataModel {
  final bool sessionClosed;
  final bool alreadyClosed;

  const LogoutDataModel({
    required this.sessionClosed,
    required this.alreadyClosed,
  });

  factory LogoutDataModel.fromJson(Map<String, dynamic> json) {
    return LogoutDataModel(
      sessionClosed: json['session_closed'] as bool,
      alreadyClosed: json['already_closed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'session_closed': sessionClosed, 'already_closed': alreadyClosed};
  }
}
