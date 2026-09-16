import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

import 'loading_event.dart';
import 'loading_state.dart';

class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final SessionBloc sessionBloc;

  StreamSubscription<SessionState>? _sessionSubscription;

  LoadingBloc({required this.sessionBloc}) : super(const LoadingState()) {
    on<LoadingStarted>(_onStarted);
    on<LoadingSessionChanged>(_onSessionChanged);
  }

  // *********************************************************
  // 1. OBSERVAR SESIÓN
  // *********************************************************
  void _onStarted(LoadingStarted event, Emitter<LoadingState> emit) {
    if (_sessionSubscription != null) return;

    _sessionSubscription = sessionBloc.stream.listen((sessionState) {
      if (!isClosed) {
        add(LoadingSessionChanged(sessionState));
      }
    });

    add(LoadingSessionChanged(sessionBloc.state));
  }

  // *********************************************************
  // 2. PROCESAR RESULTADO
  // *********************************************************
  void _onSessionChanged(
    LoadingSessionChanged event,
    Emitter<LoadingState> emit,
  ) {
    final sessionState = event.sessionState;

    switch (sessionState.status) {
      case SessionStatus.saving:
        _emitIfChanged(
          emit,
          const LoadingState(message: 'Preparando tu sesión…'),
        );
        return;

      case SessionStatus.restoring:
        _emitIfChanged(
          emit,
          const LoadingState(message: 'Recuperando tu sesión…'),
        );
        return;

      case SessionStatus.loggingOut:
        _emitIfChanged(emit, const LoadingState(message: 'Cerrando sesión…'));
        return;

      case SessionStatus.authenticated:
        _emitIfChanged(
          emit,
          const LoadingState(status: LoadingStatus.authenticated),
        );
        return;

      case SessionStatus.unauthenticated:
        final errorMessage = sessionState.errorMessage;

        if (errorMessage != null && errorMessage.isNotEmpty) {
          _emitIfChanged(
            emit,
            LoadingState(
              status: LoadingStatus.failure,
              errorMessage: errorMessage,
            ),
          );
        } else {
          _emitIfChanged(
            emit,
            const LoadingState(status: LoadingStatus.unauthenticated),
          );
        }
        return;

      case SessionStatus.initial:
        final errorMessage = sessionState.errorMessage;

        if (errorMessage != null && errorMessage.isNotEmpty) {
          _emitIfChanged(
            emit,
            LoadingState(
              status: LoadingStatus.failure,
              errorMessage: errorMessage,
            ),
          );
        } else {
          _emitIfChanged(emit, const LoadingState());
        }
        return;
    }
  }

  // *********************************************************
  // 3. EVITAR EMISIONES DUPLICADAS
  // *********************************************************
  void _emitIfChanged(Emitter<LoadingState> emit, LoadingState nextState) {
    if (state.status == nextState.status &&
        state.message == nextState.message &&
        state.errorMessage == nextState.errorMessage) {
      return;
    }

    emit(nextState);
  }

  // *********************************************************
  // 4. LIBERAR SUSCRIPCIÓN
  // *********************************************************
  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    await super.close();
  }
}
