import 'package:flutter/material.dart';

void main() {
  runApp(const MiAppCasa());
}

class MiAppCasa extends StatelessWidget {
  const MiAppCasa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Casa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Control de Gastos de la Casa'),
      ),
      body: const Center(
        child: Text(
          '¡Hola! Aquí irá nuestra lista de compras y descuentos.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}