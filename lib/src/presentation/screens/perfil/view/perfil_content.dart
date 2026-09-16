import 'package:flutter/material.dart';

class PerfilContent extends StatefulWidget {
  const PerfilContent({super.key});

  @override
  State<PerfilContent> createState() => _PerfilContentState();
}

class _PerfilContentState extends State<PerfilContent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(body: Center(child: Text("ESTAS EN PERFIL CONTENT"))),
    );
  }
}
