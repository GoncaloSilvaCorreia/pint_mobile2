import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pint_mobile/api/api.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  _ResetPage createState() => _ResetPage();
}

class _ResetPage extends State<Reset> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _emailError;
  String? _successMessage;
  final ApiClient _apiClient = ApiClient();

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final String email = _emailController.text.trim();
    bool hasError = false;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Por favor, insira o seu email.';
      });
      hasError = true;
    }

    if (hasError) return;

    try {
      final response = await _apiClient.resetPassword(email);

      if (response['success']) {
        setState(() {
          _successMessage = 'Se o e-mail estiver registado, você receberá um link para redefinir sua senha.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_successMessage!)),
        );
      } else {
        setState(() {
          _errorMessage = 'Erro ao enviar email de redefinição';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao tentar resetar a senha: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                onPressed: _resetPassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Pedir nova chave de acesso',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_successMessage != null)
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
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