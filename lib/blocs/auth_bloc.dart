import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc {
  final _controller = StreamController<User?>.broadcast();
  Stream<User?> get stream => _controller.stream;

  AuthBloc() {
    _controller.add(null); // Inicia deslogado por padrão
  }

  Future<void> login(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) throw 'Preencha todos os campos!';
    // Como estamos na Web sem o Firebase ativo, simulamos o login com sucesso
    _controller.add(MockUser(email));
  }

  Future<void> registrar(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) throw 'Preencha todos os campos!';
    _controller.add(MockUser(email));
  }

  Future<void> logout() async {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

// Classe mock apenas para simular o usuário logado na Web
class MockUser implements User {
  @override
  final String email;
  @override
  final String uid;
  MockUser(this.email) : uid = 'mock_uid_123';
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}