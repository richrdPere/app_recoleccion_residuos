
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Bloc
import 'package:app_recoleccion_residuos/src/presentation/screens/bloc.dart';

// Widgets
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/app_widgets/app_geometrical_background.dart';
import 'package:app_recoleccion_residuos/src/presentation/shared/widgets/customs/custom_input.dart';


class RegisterContent extends StatefulWidget {
  const RegisterContent({super.key});

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();

  // *********************************************************
  // 1. LIBERAR RECURSOS
  // *********************************************************

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _celularController.dispose();

    super.dispose();
  }

  // *********************************************************
  // 2. ACTUALIZAR BLOC
  // *********************************************************

  void _changeField(RegisterField field, String value) {
    context.read<RegisterBloc>().add(
      RegisterFieldChanged(field: field, value: value),
    );
  }

  // *********************************************************
  // 3. VALIDAR USANDO LAS REGLAS DEL STATE
  // *********************************************************

  String? _validate(String field) {
    // Los controladores contienen el valor actual, incluso
    // antes de que el BLoC termine de procesar un onChanged.
    final formState = RegisterState(
      nombres: _nombresController.text,
      apellidos: _apellidosController.text,
      dni: _dniController.text,
      email: _emailController.text,
      celular: _celularController.text,
    );

    return formState.errors[field];
  }

  // *********************************************************
  // 4. ENVIAR FORMULARIO
  // *********************************************************

  void _submit() {
    final bloc = context.read<RegisterBloc>();

    if (bloc.state.isLoading || bloc.state.isSuccess) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    // Sincronizar también los valores de autofill/controladores.
    bloc
      ..add(
        RegisterFieldChanged(
          field: RegisterField.nombres,
          value: _nombresController.text,
        ),
      )
      ..add(
        RegisterFieldChanged(
          field: RegisterField.apellidos,
          value: _apellidosController.text,
        ),
      )
      ..add(
        RegisterFieldChanged(
          field: RegisterField.dni,
          value: _dniController.text,
        ),
      )
      ..add(
        RegisterFieldChanged(
          field: RegisterField.email,
          value: _emailController.text,
        ),
      )
      ..add(
        RegisterFieldChanged(
          field: RegisterField.celular,
          value: _celularController.text,
        ),
      )
      ..add(const RegisterSubmitted());
  }

  // *********************************************************
  // 5. INTERFAZ
  // *********************************************************

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final blocked = state.isLoading || state.isSuccess;

        return PopScope(
          canPop: !blocked,
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              backgroundColor: colors.primary,
              resizeToAvoidBottomInset: true,
              body: AppGeometricalBackground(
                child: SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 360;
                      final horizontalPadding = compact ? 20.0 : 32.0;

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // *****************************
                              // ENCABEZADO
                              // *****************************
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  12,
                                  horizontalPadding,
                                  28,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        tooltip: 'Volver al login',
                                        onPressed: blocked
                                            ? null
                                            : () => context.go('/login'),
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                        ),
                                        color: colors.onSurface,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: compact ? 44 : 56,
                                        color: colors.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Forma parte de una Calca limpia',
                                      textAlign: TextAlign.center,
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Municipalidad Provincial de Calca',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),

                              // *****************************
                              // PANEL DEL FORMULARIO
                              // *****************************
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
                                    constraints: const BoxConstraints(
                                      maxWidth: 440,
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Crear cuenta ciudadana',
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Regístrate para configurar tu '
                                            'domicilio y activar avisos de '
                                            'recolección.',
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 28),

                                          // NOMBRES
                                          CustomInput(
                                            icon: Icons.person_outline_rounded,
                                            placeholder: 'Nombres',
                                            textController: _nombresController,
                                            keyboardType: TextInputType.name,
                                            isPassword: false,
                                            enabled: !blocked,
                                            validator: (_) =>
                                                _validate('nombres'),
                                            onChanged: (value) => _changeField(
                                              RegisterField.nombres,
                                              value,
                                            ),
                                          ),

                                          // APELLIDOS
                                          CustomInput(
                                            icon: Icons.badge_outlined,
                                            placeholder: 'Apellidos',
                                            textController:
                                                _apellidosController,
                                            keyboardType: TextInputType.name,
                                            isPassword: false,
                                            enabled: !blocked,
                                            validator: (_) =>
                                                _validate('apellidos'),
                                            onChanged: (value) => _changeField(
                                              RegisterField.apellidos,
                                              value,
                                            ),
                                          ),

                                          // DNI
                                          CustomInput(
                                            icon: Icons.credit_card_rounded,
                                            placeholder: 'DNI',
                                            textController: _dniController,
                                            keyboardType: TextInputType.number,
                                            isPassword: false,
                                            enabled: !blocked,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                8,
                                              ),
                                            ],
                                            validator: (_) => _validate('dni'),
                                            onChanged: (value) => _changeField(
                                              RegisterField.dni,
                                              value,
                                            ),
                                          ),

                                          // CORREO
                                          CustomInput(
                                            icon: Icons.email_outlined,
                                            placeholder: 'Correo electrónico',
                                            textController: _emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            isPassword: false,
                                            enabled: !blocked,
                                            validator: (_) =>
                                                _validate('email'),
                                            onChanged: (value) => _changeField(
                                              RegisterField.email,
                                              value,
                                            ),
                                          ),

                                          // CELULAR OPCIONAL
                                          CustomInput(
                                            icon: Icons.phone_outlined,
                                            placeholder: 'Celular (opcional)',
                                            textController: _celularController,
                                            keyboardType: TextInputType.phone,
                                            textInputAction:
                                                TextInputAction.done,
                                            isPassword: false,
                                            enabled: !blocked,
                                            validator: (_) =>
                                                _validate('celular'),
                                            onChanged: (value) => _changeField(
                                              RegisterField.celular,
                                              value,
                                            ),
                                          ),

                                          // INFORMACIÓN DE ACCESO
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: colors.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.info_outline_rounded,
                                                  color:
                                                      colors.onPrimaryContainer,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Tu usuario y contraseña '
                                                    'inicial serán tu DNI. '
                                                    'Después de ingresar '
                                                    'podrás cambiar tu '
                                                    'contraseña.',
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                          color: colors
                                                              .onPrimaryContainer,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),

                                          // CREAR CUENTA
                                          FilledButton(
                                            onPressed: blocked ? null : _submit,
                                            style: FilledButton.styleFrom(
                                              minimumSize: const Size(
                                                double.infinity,
                                                56,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (state.isLoading) ...[
                                                  const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                ],
                                                Flexible(
                                                  child: Text(
                                                    state.isLoading
                                                        ? 'Creando cuenta…'
                                                        : 'Crear cuenta',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // VOLVER AL LOGIN
                                          TextButton(
                                            onPressed: blocked
                                                ? null
                                                : () => context.go('/login'),
                                            child: const Text(
                                              '¿Ya tienes una cuenta? '
                                              'Inicia sesión',
                                            ),
                                          ),
                                        ],
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
            ),
          ),
        );
      },
    );
  }
}
