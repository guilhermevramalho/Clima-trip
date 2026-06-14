import 'package:flutter/material.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  final AuthBloc authBloc;
  const LoginScreen({super.key, required this.authBloc});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _modoCadastro = false;

  void _confirmarFormulario() async {
    try {
      if (_modoCadastro) {
        await widget.authBloc.registrar(_emailCtrl.text.trim(), _senhaCtrl.text.trim());
      } else {
        await widget.authBloc.login(_emailCtrl.text.trim(), _senhaCtrl.text.trim());
      }
      if (mounted) Navigator.pop(context);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha na Autenticação: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modoCadastro ? 'Criar Nova Conta' : 'Entrar no ClimaTrip')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'E-mail')),
            TextField(controller: _senhaCtrl, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _confirmarFormulario, child: Text(_modoCadastro ? 'Finalizar Cadastro' : 'Realizar Login')),
            TextButton(
              onPressed: () => setState(() => _modoCadastro = !_modoCadastro),
              child: Text(_modoCadastro ? 'Já possui login? Entre aqui' : 'Não tem conta? Cadastre-se'),
            )
          ],
        ),
      ),
    );
  }
}