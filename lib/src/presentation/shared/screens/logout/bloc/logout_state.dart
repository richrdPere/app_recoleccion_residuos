enum LogoutStatus { processing, success, failure }

class LogoutState {
  final LogoutStatus status;
  final String? errorMessage;
  final bool canRetry;
  final String returnRoute;

  const LogoutState({
    this.status = LogoutStatus.processing,
    this.errorMessage,
    this.canRetry = false,
    this.returnRoute = '/home',
  });
}
