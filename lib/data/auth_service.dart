import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get estadoAutenticacao => _auth.authStateChanges();

  Future<void> loginComEmailSenha(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> cadastrarComEmailSenha(String email, String senha) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> realizarLogout() async {
    await _auth.signOut();
  }
}