import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Mwendo GPS Engine example')),
        body: const Center(
          child: Text('Use MwendoGpsEngine().startRecording() to track a run.'),
        ),
      ),
    );
  }
}
