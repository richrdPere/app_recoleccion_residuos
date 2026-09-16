
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Modelos
import 'package:app_recoleccion_residuos/src/data/models/models.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  // *********************************************************
  // 1. LIBERAR RECURSOS
  // *********************************************************
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  // *********************************************************
  // 2. ENVIAR FORMULARIO
  // *********************************************************
  void _submit() {
    final loginState = context.read<LoginBloc>().state;
    final sessionState = context.read<SessionBloc>().state;

    if (loginState.isSubmitting ||
        sessionState.status != SessionStatus.unauthenticated) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    context.read<LoginBloc>().add(
      LoginSubmitted(
        request: LoginRequest(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      ),
    );
  }

  // *********************************************************
  // 3. INTERFAZ
  // *********************************************************
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isSubmitting = context.select(
      (LoginBloc bloc) => bloc.state.isSubmitting,
    );

    final sessionStatus = context.select(
      (SessionBloc bloc) => bloc.state.status,
    );

    final sessionError = context.select(
      (SessionBloc bloc) => bloc.state.errorMessage,
    );

    final canSubmit =
        sessionStatus == SessionStatus.unauthenticated && !isSubmitting;

    final restorationFailed =
        sessionStatus == SessionStatus.initial && sessionError != null;

    final isBusy =
        isSubmitting ||
        sessionStatus == SessionStatus.restoring ||
        sessionStatus == SessionStatus.saving ||
        (sessionStatus == SessionStatus.initial && !restorationFailed);

    final String buttonText;

    if (isSubmitting) {
      buttonText = 'Ingresando…';
    } else if (sessionStatus == SessionStatus.saving) {
      buttonText = 'Preparando sesión…';
    } else if (sessionStatus == SessionStatus.restoring ||
        sessionStatus == SessionStatus.initial) {
      buttonText = restorationFailed
          ? 'Sesión pendiente'
          : 'Verificando sesión…';
    } else {
      buttonText = 'Ingresar';
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors.primary,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final horizontalPadding = compact ? 20.0 : 32.0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // *************************************
                      // ENCABEZADO
                      // *************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          compact ? 28 : 40,
                          horizontalPadding,
                          32,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Icon(
                                Icons.local_shipping_rounded,
                                size: compact ? 48 : 60,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Recolección de residuos',
                              textAlign: TextAlign.center,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Municipalidad Provincial de Calca',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // *************************************
                      // PANEL DEL FORMULARIO
                      // *************************************
                      Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(compact ? 48 : 80),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          36,
                          horizontalPadding,
                          32 + MediaQuery.of(context).padding.bottom,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: AutofillGroup(
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Iniciar sesión',
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ingresa con tu cuenta para consultar '
                                      'tu programación y gestionar '
                                      'tu jornada.',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // USUARIO
                                    TextFormField(
                                      controller: _usernameController,
                                      enabled: canSubmit,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.username,
                                      ],
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      decoration: const InputDecoration(
                                        labelText: 'Usuario',
                                        hintText: 'Ingresa tu usuario',
                                        prefixIcon: Icon(
                                          Icons.person_outline_rounded,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Ingresa tu usuario.';
                                        }

                                        return null;
                                      },
                                      onFieldSubmitted: (_) {
                                        _passwordFocusNode.requestFocus();
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // CONTRASEÑA
                                    TextFormField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      enabled: canSubmit,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        hintText: 'Ingresa tu contraseña',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                        ),
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          tooltip: _obscurePassword
                                              ? 'Mostrar contraseña'
                                              : 'Ocultar contraseña',
                                          onPressed: canSubmit
                                              ? () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                }
                                              : null,
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingresa tu contraseña.';
                                        }

                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _submit(),
                                    ),
                                    const SizedBox(height: 28),

                                    // INGRESAR
                                    FilledButton(
                                      onPressed: canSubmit ? _submit : null,
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isBusy) ...[
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          Flexible(
                                            child: Text(
                                              buttonText,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // REINTENTAR LECTURA LOCAL
                                    if (restorationFailed) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        sessionError,
                                        textAlign: TextAlign.center,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.error,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          context.read<SessionBloc>().add(
                                            const SessionStarted(),
                                          );
                                        },
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text(
                                          'Reintentar recuperación',
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 28),
                                    Text(
                                      'Acceso para personal autorizado.\n'
                                      'Si necesitas una cuenta, comunícate '
                                      'con el administrador del sistema.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
