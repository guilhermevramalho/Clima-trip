import 'dart:async';
import '../models/cidade.dart';

class DadosUsuarioBloc {
  final _favController = StreamController<List<Cidade>>.broadcast();
  final _histController = StreamController<List<Experiencia>>.broadcast();

  Stream<List<Cidade>> get streamFavoritos => _favController.stream;
  Stream<List<Experiencia>> get streamHistorico => _histController.stream;

  final List<Cidade> _listaFavoritosCache = [];
  final List<Experiencia> _listaHistoricoCache = [];

  void carregarDadosUsuario(String uid) {
    _favController.add(_listaFavoritosCache);
    _histController.add(_listaHistoricoCache);
  }

  void alternarFavorito(String uid, Cidade cidade, bool jaFavoritado) {
    if (jaFavoritado) {
      _listaFavoritosCache.removeWhere((c) => c.nome == cidade.nome);
    } else {
      _listaFavoritosCache.add(cidade);
    }
    _favController.add(List.from(_listaFavoritosCache));
  }

  void registrarNovaExperiencia(String uid, Cidade cidade) {
    final agora = DateTime.now();
    final dataStr = '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}';
    
    final novaExp = Experiencia(
      id: agora.millisecondsSinceEpoch.toString(),
      cidade: cidade.nome,
      data: dataStr,
      clima: cidade.descClima,
      temperatura: cidade.temperatura,
    );
    
    _listaHistoricoCache.add(novaExp);
    _histController.add(List.from(_listaHistoricoCache));
  }

  void apagarExperiencia(String uid, String idExperiencia) {
    _listaHistoricoCache.removeWhere((exp) => exp.id == idExperiencia);
    _histController.add(List.from(_listaHistoricoCache));
  }

  void dispose() {
    _favController.close();
    _histController.close();
  }
}