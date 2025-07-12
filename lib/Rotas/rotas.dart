//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pint_mobile/screens/Login/Login.dart';
import 'package:pint_mobile/screens/Login/Contacto.dart';
import 'package:pint_mobile/screens/Login/Reset.dart';
import 'package:pint_mobile/screens/Inicio/Inicio.dart';
import 'package:pint_mobile/screens/Perfil/Perfil.dart';
import 'package:pint_mobile/screens/Curso/MeusCursos.dart';
import 'package:pint_mobile/screens/Forum/Forum.dart';
import 'package:provider/provider.dart';
import 'package:pint_mobile/utils/auth_provider.dart';
import 'package:pint_mobile/screens/Pesquisa/Pesquisa.dart';

final rotas = GoRouter(
  initialLocation: '/Login',
  routes: [
    GoRoute(
      name: 'Login',
      path: '/Login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      name: 'Contacto',
      path: '/Contacto',
      builder: (context, state) => Contacto(),
    ),
    GoRoute(
      name: 'Reset',
      path: '/Reset',
      builder: (context, state) => Reset(),
    ),
    GoRoute(
      name: 'TelaPrincipal',
      path: '/TelaPrincipal',
      builder: (context, state) => TelaPrincipal(),
    ),
    GoRoute(
      name: 'Pesquisa',
      path: '/pesquisar',
      builder: (context, state) => const Pesquisa(),
    ),
    GoRoute(
      name: 'Perfil',
      path: '/perfil',
      builder: (context, state) {
        final workerNumber = state.extra as String?;
        return Perfil(workerNumber: workerNumber ?? '');
      },
    ),
    GoRoute(
      name: 'MeusCursos',
      path: '/meus-cursos',
      builder: (context, state) => const MeusCursos(),
    ),
    GoRoute(
      name: 'Forum',
      path: '/Forum',
      builder: (context, state) => Forum(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    final isLoginRoute = state.uri.toString() == '/Login';
    final isResetRoute = state.uri.toString() == '/Reset';
    final isContactoRoute = state.uri.toString() == '/Contacto';

    if (!isLoggedIn && !(isLoginRoute || isResetRoute || isContactoRoute)) {
      return '/Login';
    }

    if (isLoggedIn && isLoginRoute) {
      return '/TelaPrincipal';
    }

    return null;
  },
);