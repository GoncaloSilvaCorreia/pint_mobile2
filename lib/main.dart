import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Rotas/rotas.dart';
import 'utils/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(), 
      child: const SoftinsaLoginApp(),
    ),
  );
}

class SoftinsaLoginApp extends StatelessWidget {
  const SoftinsaLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: rotas,
      title: 'Softinsa Login',
    );
  } 
}