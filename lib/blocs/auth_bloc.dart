import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_service.dart';

class AuthBloc {
  final AuthService _authService = AuthService();
  final _controller = StreamController<User?>.broadcast();
  Stream<User?> get stream => _controller.stream;

  AuthBloc() {
    // Escuta o estado real de autenticação do Firebase
    _authService.estadoAutenticacao.listen((user) {
      _controller.add(user);
    });
  }

  Future<void> login(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) throw 'Preencha todos os campos!';
    await _authService.loginComEmailSenha(email, senha);
  }

  Future<void> registrar(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) throw 'Preencha todos os campos!';
    await _authService.cadastrarComEmailSenha(email, senha);
  }

  Future<void> logout() async {
    await _authService.realizarLogout();
  }

  void dispose() {
    _controller.close();
  }
}