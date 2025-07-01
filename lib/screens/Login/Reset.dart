import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  _ResetPage createState() => _ResetPage();
}

class _ResetPage extends State<Reset> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError; 

  Future<void> resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Por favor, insira o seu email.';
      });
      return;
    }

    setState(() {
      _emailError = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de recuperação enviado com sucesso. Verifique a sua caixa de entrada.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar email de recuperação: $e')),
      );
    }
  }

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
              child: Text('Recuperação de acesso',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Por favor, introduza o seu e-mail para recuperação',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text('Email'),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Insira o seu e-mail institucional',
                border: OutlineInputBorder(),
                errorText: _emailError,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailError != null ? Colors.red : Colors.indigo,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailError != null ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                onPressed: resetPassword,
                child: const Text(
                  'Pedir nova chave de acesso',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Não tem uma conta? '),
                GestureDetector(
                  onTap: () => context.go('/Contacto'),
                  child: const Text(
                    'Contactar',
                    style: TextStyle(color: Colors.cyan),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
