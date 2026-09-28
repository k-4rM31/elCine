import 'package:flutter/material.dart';

class CineIaScreen extends StatelessWidget {
  const CineIaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ciné IA')),
      body: const Center(child: Text('Assistant à venir')),
    );
  }
}