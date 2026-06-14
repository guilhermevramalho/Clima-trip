import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cidade.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CRUD FAVORITOS ---
  Future<void> salvarFavorito(String userId, Cidade cidade) async {
    await _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('favoritos')
        .doc(cidade.nome)
        .set(cidade.toMap());
  }

  Future<void> deletarFavorito(String userId, String nomeCidade) async {
    await _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('favoritos')
        .doc(nomeCidade)
        .delete();
  }

  Stream<List<Cidade>> escutarFavoritos(String userId) {
    return _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('favoritos')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Cidade.fromMap(doc.data())).toList());
  }

  // --- CRUD HISTÓRICO DE EXPERIÊNCIAS ---
  Future<void> salvarExperiencia(String userId, String cidade, int temp, String clima) async {
    final docRef = _firestore.collection('usuarios').doc(userId).collection('historico').doc();
    final exp = Experiencia(
      id: docRef.id,
      cidade: cidade,
      data: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      clima: clima,
      temperatura: temp,
    );
    await docRef.set(exp.toMap());
  }

  Future<void> deletarExperiencia(String userId, String idExp) async {
    await _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('historico')
        .doc(idExp)
        .delete();
  }

  Stream<List<Experiencia>> escutarHistorico(String userId) {
    return _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('historico')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Experiencia.fromMap(doc.data())).toList());
  }
}