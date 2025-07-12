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

  void _mostrarSucesso(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Email Enviado'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erro no Envio'),
        content: SingleChildScrollView(child: Text(mensagem)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _emailError = null;
    });

    final String email = _emailController.text.trim();
    bool hasError = false;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Por favor, insira o seu email.';
      });
      hasError = true;
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Por favor, insira um email válido.';
      });
      hasError = true;
    }

    if (hasError) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _apiClient.resetPassword(email);

      if (response['success'] == true) {
        setState(() {
          _successMessage = response['message'];
          _errorMessage = null; 
        });
        
        _emailController.clear(); 
        _mostrarSucesso(_successMessage!); 
      } else {
        setState(() {
          _errorMessage = response['message']; 
          _successMessage = null; 
          
          if (_errorMessage!.toLowerCase().contains('email')) {
            _emailError = _errorMessage;
          }
        });
        _mostrarErro(_errorMessage!);
      }
    } catch (e) {
      String errorMsg = 'Erro ao tentar resetar a senha: ${e.toString()}';
      setState(() {
        _errorMessage = errorMsg;
        _successMessage = null;
        
        if (e.toString().toLowerCase().contains('email')) {
          _emailError = 'Formato de e-mail inválido';
        }
      });
      _mostrarErro(errorMsg);
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
                    width: _emailError != null ? 2.0 : 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailError != null ? Colors.red : Colors.grey,
                  ),
                ),
                errorStyle: TextStyle(color: Colors.red[700]),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[700]!, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                onPressed: _isLoading ? null : _resetPassword,
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
                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
            if (_successMessage != null)
              Text(
                _successMessage!,
                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
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