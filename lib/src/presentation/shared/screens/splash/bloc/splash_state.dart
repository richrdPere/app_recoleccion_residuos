enum SplashStatus { loading, authenticated, unauthenticated, failure }

class SplashState {
  final SplashStatus status;
  final String? errorMessage;

  const SplashState({this.status = SplashStatus.loading, this.errorMessage});
}
