import 'package:flutter/material.dart';

class UnrealEngine extends StatefulWidget {
  const UnrealEngine({super.key});

  @override
  State<UnrealEngine> createState() => _UnrealEngineState();
}

class _UnrealEngineState extends State<UnrealEngine> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Games Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text('Game Score: $_counter', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: const Text('Increase Score'),
        ),
      ],
    );
  }
}
