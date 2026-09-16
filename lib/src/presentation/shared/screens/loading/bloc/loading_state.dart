enum LoadingStatus { processing, authenticated, unauthenticated, failure }

class LoadingState {
  final LoadingStatus status;
  final String message;
  final String? errorMessage;

  const LoadingState({
    this.status = LoadingStatus.processing,
    this.message = 'Preparando tu sesión…',
    this.errorMessage,
  });
}
