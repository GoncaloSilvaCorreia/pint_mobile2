import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Rodape extends StatelessWidget {
  final String workerNumber;

  const Rodape({super.key, required this.workerNumber});
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF3F51B5),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Pesquisar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Meus Cursos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/TelaPrincipal');
            break;
          case 1:
            context.go('/pesquisar');
            break;
          case 2:
            context.go('/meus-cursos');
            break;
          case 3:
            context.go('/perfil', extra: workerNumber);
            break;
        }
      },
    );
  }
}

