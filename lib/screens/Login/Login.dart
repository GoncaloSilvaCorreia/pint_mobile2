import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pint_mobile/api/api_utilizador.dart';
import 'package:pint_mobile/api/auth_service.dart';
import 'package:pint_mobile/utils/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool hasError = false;

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Por favor, insira o seu email.';
      });
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Por favor, insira a sua password.';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final utilizador = await _authService.login(email, password);

      if (utilizador != null) {
        if (mounted) {
          context.read<AuthProvider>().login(utilizador.token, utilizador); 
          
          context.go('/'); // ISTO TEM DE ESTAR SENÃO O LOGIN NÃO VAI DAR
          context.go('/TelaPrincipal');
        }
      } else {
        setState(() {
          _passwordError = 'Credenciais incorretas ou utilizador não existe.';
        });
      }
    } on Exception catch (e) {
      String errorMessage;

      if (e.toString().contains('password')) {
        errorMessage = 'Password incorreta.';
        setState(() {
          _passwordError = errorMessage;
        });
      } else if (e.toString().contains('not found') || e.toString().contains('404')) {
        errorMessage = 'Utilizador não encontrado.';
        setState(() {
          _emailError = errorMessage;
        });
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Erro de ligação. API indisponível.';
      } else {
        errorMessage = 'Erro: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'SOF', style: TextStyle(color: Color(0xFF3F51B5))),
                  TextSpan(text: 'T', style: TextStyle(color: Colors.cyan)),
                  TextSpan(text: 'INSA', style: TextStyle(color: Colors.indigo)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Entre na sua conta',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bem-vindo! Por favor, introduza os seus dados.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Insira o seu e-mail institucional',
                border: const OutlineInputBorder(),
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
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Insira a palavra passe',
                border: const OutlineInputBorder(),
                errorText: _passwordError,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _passwordError != null ? Colors.red : Colors.indigo,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _passwordError != null ? Colors.red : Colors.grey,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => context.go('/Reset'),
                  child: const Text(
                    'Esqueci-me dos dados',
                    style: TextStyle(color: Colors.cyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Entrar', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Não tem uma conta? '),
                TextButton(
                  onPressed: () => context.go('/Contacto'),
                  child: const Text(
                    'Contactar gestor',
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