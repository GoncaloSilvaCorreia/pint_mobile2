import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pint_mobile/api/api.dart';

class Contacto extends StatefulWidget {
  const Contacto({super.key});

  @override
  State<Contacto> createState() => _ContactoState();
}

class _ContactoState extends State<Contacto> {
  final _workerNumberController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String? _workerNumberError;
  String? _fullNameError;
  String? _emailError;
  String? _subjectError;
  String? _messageError;

  bool _isLoading = false;
  String? _selectedSubject;

  final List<String> _subjects = [
    'Criar Conta',
    'Problemas com o login',
    'Problemas técnicos no site',
    'Feedback/Sugestões',
    'Outros'
  ];

  final ApiClient _apiClient = ApiClient(); 

  Future<void> _handleSubmit() async {
    setState(() {
      _workerNumberError = null;
      _fullNameError = null;
      _emailError = null;
      _subjectError = null;
      _messageError = null;
    });

    String workerNumber = _workerNumberController.text.trim();
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String subject = _selectedSubject ?? ''; 
    String message = _messageController.text.trim();

    bool hasError = false;

    if (workerNumber.isEmpty) {
      setState(() {
        _workerNumberError = 'Por favor, insira o Nº de Trabalhador.';
      });
      hasError = true;
    }

    if (fullName.isEmpty) {
      setState(() {
        _fullNameError = 'Por favor, insira o Nome Completo.';
      });
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Por favor, insira o seu e-mail Institucional.';
      });
      hasError = true;
    }

    if (subject.isEmpty) {
      setState(() {
        _subjectError = 'Por favor, selecione o Assunto.';
      });
      hasError = true;
    }

    if (message.isEmpty) {
      setState(() {
        _messageError = 'Por favor, insira a Mensagem.';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.sendContactForm(
        workerNumber,
        fullName,
        email,
        subject,
        message,
      );

      if (response['success'] == true) {

        _workerNumberController.clear();
        _fullNameController.clear();
        _emailController.clear();
        _messageController.clear();
        setState(() {
          _selectedSubject = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de comunicação: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _workerNumberController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
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
            const Text('Número Trabalhador'),
            const SizedBox(height: 4),
            TextField(
              controller: _workerNumberController,
              decoration: InputDecoration(
                hintText: 'Insira o Nº de Trabalhador',
                border: const OutlineInputBorder(),
                errorText: _workerNumberError,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nome completo'),
            const SizedBox(height: 4),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Insira o Primeiro e Último Nome',
                border: const OutlineInputBorder(),
                errorText: _fullNameError,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Email'),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Insira o seu e-mail Institucional',
                border: const OutlineInputBorder(),
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Assunto'),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSubject = newValue;
                });
              },
              decoration: InputDecoration(
                hintText: 'Selecione um assunto',
                border: const OutlineInputBorder(),
                errorText: _subjectError,
              ),
              items: _subjects.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Mensagem'),
            const SizedBox(height: 4),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Escreva aqui o seu Pedido ou Sugestão',
                border: const OutlineInputBorder(),
                errorText: _messageError,
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
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar formulário', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}