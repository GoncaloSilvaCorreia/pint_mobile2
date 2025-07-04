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
            // Itens do menu
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(context, Icons.library_books, 'Cursos', '/cursos', selected: true),
                  _buildMenuItem(context, Icons.bookmark, 'Meus cursos', '/meus-cursos'),
                  _buildMenuItem(context, Icons.forum, 'Fórum', '/forum'),
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
                  Navigator.of(context).pop(); // Serve para fechar o menu lateral
                  context.read<AuthProvider>().logout(); // Faz o método logout do authProvider
                  context.go('/Login'); // Vai para a tela /Login
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route, {bool selected = false}) {
    final color = selected ? Colors.indigo.shade100 : Colors.black;
    final bgColor = selected ? Colors.indigo.shade100.withOpacity(0.5) : Colors.transparent;

    return Container(
      color: bgColor,
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.indigo : Colors.black),
        title: Text(title, style: TextStyle(color: color)),
        onTap: () async {
          // Obtém o workerNumber de SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? workerNumber = prefs.getString('workerNumber');

          // Fecha o menu lateral
          Navigator.of(context).pop();

          // Verifica se o workerNumber está presente e navega para a tela de perfil com o workerNumber
          if (workerNumber != null) {
            context.go('/perfil', extra: workerNumber);  // Passa workerNumber para a tela de perfil
          } else {
            // Caso não exista workerNumber, exibe uma mensagem de erro
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro: WorkerNumber não encontrado.'))
            );
          }
        },
      ),
    );
  }
}
