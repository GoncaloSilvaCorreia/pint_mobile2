import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:pint/api/api.dart';

class Contacto extends StatelessWidget {
  const Contacto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/Login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: 'SOF', style: TextStyle(color: Colors.indigo)),
                    TextSpan(text: 'T', style: TextStyle(color: Colors.cyan)),
                    TextSpan(text: 'INSA', style: TextStyle(color: Colors.indigo)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text('Formulário de contacto',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Por favor, introduza os seus dados',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Nome completo'),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Insira o primeiro e último nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Email'),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Insira o seu e-mail institucional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Assunto'),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Mencione o motivo pelo contacto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Mensagem'),
            const SizedBox(height: 4),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escreva aqui o seu pedido ou sugestão',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/Reset'),
              child: const Text(
                'Esqueci-me dos dados',
                style: TextStyle(color: Colors.cyan),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                onPressed: () {},
                child: const Text('Enviar formulário', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
