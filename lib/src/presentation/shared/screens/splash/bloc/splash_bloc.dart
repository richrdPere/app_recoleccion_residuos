import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SessionBloc sessionBloc;

  StreamSubscription<SessionState>? _sessionSubscription;

  SplashBloc({required this.sessionBloc}) : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
    on<SplashSessionChanged>(_onSessionChanged);
    on<SplashRetryRequested>(_onRetryRequested);
  }

  // *********************************************************
  // 1. OBSERVAR SESIÓN
  // *********************************************************
  void _onStarted(SplashStarted event, Emitter<SplashState> emit) {
    if (_sessionSubscription != null) return;

    _sessionSubscription = sessionBloc.stream.listen((sessionState) {
      if (!isClosed) {
        add(SplashSessionChanged(sessionState));
      }
    });

    // Procesa también una restauración que ya haya terminado.
    add(SplashSessionChanged(sessionBloc.state));
  }

  // *********************************************************
  // 2. INTERPRETAR ESTADO DE SESIÓN
  // *********************************************************
  void _onSessionChanged(
    SplashSessionChanged event,
    Emitter<SplashState> emit,
  ) {
    final sessionState = event.sessionState;

    switch (sessionState.status) {
      case SessionStatus.authenticated:
        _emitIfChanged(
          emit,
          const SplashState(status: SplashStatus.authenticated),
        );
        return;

      case SessionStatus.unauthenticated:
        _emitIfChanged(
          emit,
          const SplashState(status: SplashStatus.unauthenticated),
        );
        return;

      case SessionStatus.initial:
        final errorMessage = sessionState.errorMessage;

        if (errorMessage != null && errorMessage.isNotEmpty) {
          _emitIfChanged(
            emit,
            SplashState(
              status: SplashStatus.failure,
              errorMessage: errorMessage,
            ),
          );
        } else {
          _emitIfChanged(emit, const SplashState());
        }
        return;

      case SessionStatus.restoring:
      case SessionStatus.saving:
      case SessionStatus.loggingOut:
        _emitIfChanged(emit, const SplashState());
        return;
    }
  }

  // *********************************************************
  // 3. REINTENTAR RESTAURACIÓN
  // *********************************************************
  void _onRetryRequested(
    SplashRetryRequested event,
    Emitter<SplashState> emit,
  ) {
    if (state.status != SplashStatus.failure) return;

    emit(const SplashState());

    sessionBloc.add(const SessionStarted());
  }

  // *********************************************************
  // 4. EVITAR RESULTADOS DUPLICADOS
  // *********************************************************
  void _emitIfChanged(Emitter<SplashState> emit, SplashState nextState) {
    if (state.status == nextState.status &&
        state.errorMessage == nextState.errorMessage) {
      return;
    }

    emit(nextState);
  }

  // *********************************************************
  // 5. LIBERAR SUSCRIPCIÓN
  // *********************************************************
  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();

    // SessionBloc es global: no se cierra aquí.
    await super.close();
  }
}
