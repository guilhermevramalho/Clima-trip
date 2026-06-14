import '../models/cidade.dart';
import '../data/firestore_service.dart';

class DadosUsuarioBloc {
  final FirestoreService _firestoreService = FirestoreService();

  // Streams diretos do Firestore — dados persistentes em tempo real
  Stream<List<Cidade>> get streamFavoritos => const Stream.empty();
  Stream<List<Experiencia>> get streamHistorico => const Stream.empty();

  Stream<List<Cidade>> streamFavoritosDoUsuario(String uid) {
    return _firestoreService.escutarFavoritos(uid);
  }

  Stream<List<Experiencia>> streamHistoricoDoUsuario(String uid) {
    return _firestoreService.escutarHistorico(uid);
  }

  void carregarDadosUsuario(String uid) {
    // Não precisa fazer nada — os streams do Firestore já são reativos
  }

  Future<void> alternarFavorito(String uid, Cidade cidade, bool jaFavoritado) async {
    if (jaFavoritado) {
      await _firestoreService.deletarFavorito(uid, cidade.nome);
    } else {
      await _firestoreService.salvarFavorito(uid, cidade);
    }
  }

  Future<void> registrarNovaExperiencia(String uid, Cidade cidade) async {
    await _firestoreService.salvarExperiencia(
      uid,
      cidade.nome,
      cidade.temperatura,
      cidade.descClima,
    );
  }

  Future<void> apagarExperiencia(String uid, String idExperiencia) async {
    await _firestoreService.deletarExperiencia(uid, idExperiencia);
  }

  Future<void> editarExperiencia(String uid, String idExperiencia, String novaCidade) async {
    await _firestoreService.editarExperiencia(uid, idExperiencia, novaCidade);
  }

  void dispose() {
    // Nada a fechar — Firestore gerencia seus próprios streams
  }
}