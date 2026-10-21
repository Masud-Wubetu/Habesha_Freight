import 'package:flutter/material.dart';

class RateDriverScreen extends StatelessWidget {
  const RateDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Driver')),
      body: const Center(
        child: Text('Rate Driver Screen'),
      ),
    );
  }
}