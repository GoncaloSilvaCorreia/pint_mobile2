import 'package:flutter/material.dart';
import 'package:pint_mobile/api/api_utilizador.dart';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  final String workerNumber;

  const Perfil({Key? key, required this.workerNumber}) : super(key: key);

  @override
  State<Perfil> createState() => PerfilScreenState();
}

class PerfilScreenState extends State<Perfil> {
  final ApiUtilizador api = ApiUtilizador();
  late Future<Utilizador> _futureUtilizador;
  String _workerNumber = '';

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _futureUtilizador = api.getUtilizadorByWorkerNumber(widget.workerNumber);
  }

  Future<void> _loadWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber') ?? '';
    setState(() {
      _workerNumber = workerNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      endDrawer: const SideMenu(),  // SideMenu no lado direito
      body: FutureBuilder<Utilizador>(
        future: _futureUtilizador,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final utilizador = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      utilizador.pfp ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${utilizador.nome}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Função: ${utilizador.roles.join(', ')}'),
                  Text('ID: ${utilizador.id}'),
                  Text('E-mail: ${utilizador.email}'),
                  SizedBox(height: 20),

                  // Exibindo os interesses como texto simples
                  const Text(
                    'As minhas preferências',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: utilizador.interests
                        .map(
                          (interesse) => Text(
                            interesse['description'], // Agora acessível corretamente
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        .toList(),
                  ),
                  // Cursos concluídos (exemplo de visualização)
                  const SizedBox(height: 20),
                  const Text(
                    'Cursos concluídos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Aqui você pode implementar o código para exibir os cursos concluídos, por exemplo, com ListView
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
    );
  }
}
