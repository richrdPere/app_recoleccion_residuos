import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final TextEditingController textController;
  final TextInputType keyboardType;
  final bool isPassword;
  final Function(String)? onChanged;

  final FormFieldValidator<String>? validator;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;

  const CustomInput({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.textController,
    required this.keyboardType,
    required this.isPassword,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 5),
            blurRadius: 5,
          ),
        ],
      ),
      child: TextFormField(
        controller: textController,
        enabled: enabled,
        autocorrect: false,
        keyboardType: keyboardType,
        obscureText: isPassword,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo requerido';
              }

              return null;
            },
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: placeholder,
          border: InputBorder.none,
          prefixIcon: Icon(icon),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
            minHeight: 50,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class CustomInput extends StatelessWidget {
//   final IconData icon;
//   final String placeholder;
//   final TextEditingController textController;
//   final TextInputType keyboardType;
//   final bool isPassword;
//   final Function(String)? onChanged;

//   const CustomInput({
//     super.key,
//     required this.icon,
//     required this.placeholder,
//     required this.textController,
//     required this.keyboardType,
//     required this.isPassword,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, 5),
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: textController,
//         autocorrect: false,
//         keyboardType: keyboardType,
//         obscureText: isPassword,
//         onChanged: onChanged,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Campo requerido';
//           }
//           return null;
//         },
//         textAlignVertical: TextAlignVertical.center,
//         decoration: InputDecoration(
//           hintText: placeholder,
//           border: InputBorder.none,
//           prefixIcon: Icon(icon),
//           prefixIconConstraints: const BoxConstraints(
//             minWidth: 50,
//             minHeight: 50,
//           ),
//           isDense: true,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 18,
//             horizontal: 10,
//           ),
//         ),
//       ),
//     );
//   }
// }
