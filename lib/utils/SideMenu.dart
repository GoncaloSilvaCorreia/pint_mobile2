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
            // Cabeçalho com título e botão fechar
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
            // Itens do menu (todos com a mesma aparência)
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(context, Icons.library_books, 'Cursos', '/pesquisar'),
                  _buildMenuItem(context, Icons.bookmark, 'Meus cursos', '/meus-cursos'),
                  _buildMenuItem(context, Icons.forum, 'Fórum', '/Forum'), // Corrigido para maiúsculo
                  _buildMenuItem(context, Icons.account_circle, 'Perfil', '/perfil'),
                ],
              ),
            ),
            // Botão sair
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
        // Obtém o workerNumber de SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? workerNumber = prefs.getString('workerNumber');

        // Fecha o menu lateral
        Navigator.of(context).pop();

        // Verifica se o workerNumber está presente
        if (workerNumber != null) {
          // Navegação para diferentes rotas
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