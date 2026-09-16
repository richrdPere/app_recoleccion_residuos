import 'package:flutter/material.dart';

class MiRecorridoContent extends StatefulWidget {
  const MiRecorridoContent({super.key});

  @override
  State<MiRecorridoContent> createState() => _MiRecorridoContentState();
}

class _MiRecorridoContentState extends State<MiRecorridoContent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Center(child: Text("ESTAS EN MI RECORRIDO CONTENT")),
      ),
    );
  }
}
