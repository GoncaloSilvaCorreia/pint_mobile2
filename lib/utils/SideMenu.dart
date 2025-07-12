import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pint_mobile/utils/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MENU',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(context, Icons.library_books, 'Cursos', '/pesquisar'),
                  _buildMenuItem(context, Icons.bookmark, 'Meus cursos', '/meus-cursos'),
                  _buildMenuItem(context, Icons.forum, 'Fórum', '/Forum'), 
                  _buildMenuItem(context, Icons.account_circle, 'Perfil', '/perfil'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.black),
                title: const Text('Sair'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<AuthProvider>().logout();
                  context.go('/Login');
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? workerNumber = prefs.getString('workerNumber');

        Navigator.of(context).pop();

        if (workerNumber != null) {
          if (route == '/perfil') {
            context.go('/perfil', extra: workerNumber);
          } else {
            context.go(route);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: WorkerNumber não encontrado.'))
          );
        }
      },
    );
  }
}