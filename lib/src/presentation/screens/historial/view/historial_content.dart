import 'package:flutter/material.dart';

class HistorialContent extends StatefulWidget {
  const HistorialContent({super.key});

  @override
  State<HistorialContent> createState() => _HistorialContentState();
}

class _HistorialContentState extends State<HistorialContent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(body: Center(child: Text("ESTAS EN HISTORIAL CONTENT"))),
    );
  }
}
