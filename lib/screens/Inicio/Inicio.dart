import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  String _workerNumber = '';

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
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
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),

      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'SOF', style: TextStyle(color: Color(0xFF3F51B5))),
                  TextSpan(text: 'T', style: TextStyle(color: Colors.cyan)),
                  TextSpan(text: 'INSA', style: TextStyle(color: Color(0xFF3F51B5))),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Ação do ícone de notificações
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Melhor Rating',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Card Melhor Rating
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/jsx.jpg',
                      fit: BoxFit.contain,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('JavaScript e JSX', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star_border, color: Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Novos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Card Novos
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/curso_mobile.jpg',
                      fit: BoxFit.contain,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Desenvolvimento de Apps', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star, color: Colors.yellow),
                      Icon(Icons.star_half, color: Colors.yellow),
                      Icon(Icons.star_border, color: Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
    );
  }
}
