import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/dados_usuario_bloc.dart';
import '../blocs/weather_bloc.dart';
import '../data/weather_service.dart';
import '../models/cidade.dart';
import '../widgets/cidade_card.dart';
import 'login_screen.dart';
import 'sucesso_favorito_screen.dart';
import 'sucesso_experiencia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _abaAtual = 0;
  final AuthBloc _authBloc = AuthBloc();
  final DadosUsuarioBloc _userBloc = DadosUsuarioBloc();
  final WeatherBloc _weatherBloc = WeatherBloc(weatherService: WeatherService());

  User? _usuarioLogado;

  String _climaSelecionado = 'qualquer';
  String _estadoSelecionado = 'todos';
  double _tempMin = 0;
  double _tempMax = 45;

  FiltroClima get _filtroAtual => FiltroClima(
        clima: _climaSelecionado,
        estado: _estadoSelecionado,
        tempMin: _tempMin,
        tempMax: _tempMax,
      );

  @override
  void initState() {
    super.initState();
    _authBloc.stream.listen((user) {
      setState(() => _usuarioLogado = user);
    });
  }

  @override
  void dispose() {
    _authBloc.dispose();
    _userBloc.dispose();
    _weatherBloc.dispose();
    super.dispose();
  }

  void _abrirSucessoFavorito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SucessoFavoritoScreen(
          onVerFavoritos: () => setState(() => _abaAtual = 2),
        ),
      ),
    );
  }

  void _abrirSucessoExperiencia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SucessoExperienciaScreen(
          onVerHistorico: () => setState(() => _abaAtual = 3),
        ),
      ),
    );
  }

  void _alertaLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ação restrita! Por favor, faça login primeiro.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ClimaTrip',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
            Text(
              _usuarioLogado != null
                  ? 'Olá, ${_usuarioLogado!.email!.split('@').first}! 🌟'
                  : 'Descubra seu próximo destino',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        actions: [
          _usuarioLogado != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: () => _authBloc.logout(),
                )
              : IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => LoginScreen(authBloc: _authBloc))),
                ),
        ],
      ),
      body: IndexedStack(
        index: _abaAtual,
        children: [
          _abaDestaques(),
          _abaBuscar(),
          _abaFavoritosFirestore(),
          _abaHistoricoFirestore(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _abaAtual = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),     label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search),   label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.history),  label: 'Histórico'),
        ],
      ),
    );
  }

  Widget _abaDestaques() {
    final cidadesDestaque = [
      Cidade(
        nome: 'Florianópolis', pais: 'BR', temperatura: 26, clima: 'agradavel',
        descClima: 'Céu limpo', atividade: 'Aproveitar praias e caminhadas',
        roupa: 'Roupas leves e bermuda', icone: '☀️',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
      ),
      Cidade(
        nome: 'Gramado', pais: 'BR', temperatura: 12, clima: 'frio',
        descClima: 'Nevoeiro encorpado', atividade: 'Visitar cafés e comer fondue',
        roupa: 'Casaco pesado e cachecol', icone: '❄️',
        imageUrl: 'https://images.unsplash.com/photo-1485594050903-8e8ee7b071a8?w=600',
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Destinos Recomendados hoje:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...cidadesDestaque.map((c) =>
            CidadeCard(cidade: c, favoritado: false, onFavoritoPressed: () {})),
      ],
    );
  }

  Widget _abaBuscar() {
    return StreamBuilder<WeatherState>(
      stream: _weatherBloc.stream,
      initialData: const WeatherState(),
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _painelFiltros(state.buscando),
                    const Divider(height: 1),
                    _resultadosBusca(state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _painelFiltros(bool buscando) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('TIPO DE CLIMA'),
          const SizedBox(height: 8),
          _seletorChips(
            opcoes: const [
              {'value': 'qualquer', 'label': '🌍 Qualquer'},
              {'value': 'calor',    'label': '☀️ Calor'},
              {'value': 'agradavel','label': '🌤️ Agradável'},
              {'value': 'frio',     'label': '❄️ Frio'},
              {'value': 'chuva',    'label': '🌧️ Chuva'},
            ],
            selecionado: _climaSelecionado,
            onSelect: (v) => setState(() => _climaSelecionado = v),
          ),
          const SizedBox(height: 14),
          _label('FAIXA DE TEMPERATURA'),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('${_tempMin.round()}°C',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
              Expanded(
                child: RangeSlider(
                  values: RangeValues(_tempMin, _tempMax),
                  min: 0,
                  max: 45,
                  divisions: 45,
                  activeColor: const Color(0xFF1565C0),
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (v) => setState(() {
                    _tempMin = v.start;
                    _tempMax = v.end;
                  }),
                ),
              ),
              Text('${_tempMax.round()}°C',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
            ],
          ),
          const SizedBox(height: 10),
          _label('ESTADO'),
          const SizedBox(height: 8),
          _seletorEstado(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: buscando ? null : () => _weatherBloc.buscarPorFiltros(_filtroAtual),
              icon: buscando
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.travel_explore, size: 18),
              label: Text(buscando ? 'Consultando API...' : 'Buscar destinos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _resultadosBusca(WeatherState state) {
    if (state.buscando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Consultando dados de clima em tempo real...',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ]),
      );
    }

    if (!state.buscaFeita) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Text('🌍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Escolha os filtros e\ntoque em Buscar destinos',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ]),
      );
    }

    if (state.resultados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Text('😔', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Nenhum destino encontrado\npara os filtros selecionados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ]),
      );
    }

    if (_usuarioLogado == null) {
      return Column(
        children: [
          ...state.resultados.map((c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CidadeCard(cidade: c, favoritado: false, onFavoritoPressed: _alertaLogin),
              )),
          if (state.poolRestante.isNotEmpty) _botaoCarregarMais(state.carregandoMais),
          const SizedBox(height: 16),
        ],
      );
    }

    return StreamBuilder<List<Cidade>>(
      stream: _userBloc.streamFavoritosDoUsuario(_usuarioLogado!.uid),
      builder: (context, favSnap) {
        final listaFavs = favSnap.data ?? [];
        return Column(
          children: [
            ...state.resultados.map((cidade) {
              final jaFav = listaFavs.any((f) => f.nome == cidade.nome);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CidadeCard(
                  cidade: cidade,
                  favoritado: jaFav,
                  onFavoritoPressed: () async {
                    await _userBloc.alternarFavorito(_usuarioLogado!.uid, cidade, jaFav);
                    if (!jaFav) _abrirSucessoFavorito();
                  },
                  onSalvarExperiencia: () async {
                    await _userBloc.registrarNovaExperiencia(_usuarioLogado!.uid, cidade);
                    _abrirSucessoExperiencia();
                  },
                ),
              );
            }),
            if (state.poolRestante.isNotEmpty) _botaoCarregarMais(state.carregandoMais),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _botaoCarregarMais(bool carregandoMais) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: carregandoMais
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()))
          : OutlinedButton.icon(
              onPressed: () => _weatherBloc.carregarMais(_filtroAtual),
              icon: const Icon(Icons.expand_more),
              label: const Text('Carregar mais destinos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
                side: const BorderSide(color: Color(0xFF1565C0)),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
    );
  }

  Widget _abaFavoritosFirestore() {
    if (_usuarioLogado == null) {
      return const Center(child: Text('Faça Login para visualizar os favoritos salvos.'));
    }
    return StreamBuilder<List<Cidade>>(
      stream: _userBloc.streamFavoritosDoUsuario(_usuarioLogado!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final favoritos = snapshot.data!;
        if (favoritos.isEmpty) {
          return const Center(child: Text('Nenhum destino favoritado ainda.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoritos.length,
          itemBuilder: (context, index) {
            final item = favoritos[index];
            return CidadeCard(
              cidade: item,
              favoritado: true,
              onFavoritoPressed: () =>
                  _userBloc.alternarFavorito(_usuarioLogado!.uid, item, true),
            );
          },
        );
      },
    );
  }

  Widget _abaHistoricoFirestore() {
    if (_usuarioLogado == null) {
      return const Center(child: Text('Faça Login para gerenciar seu histórico.'));
    }
    return StreamBuilder<List<Experiencia>>(
      stream: _userBloc.streamHistoricoDoUsuario(_usuarioLogado!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final historico = snapshot.data!;
        if (historico.isEmpty) {
          return const Center(child: Text('Nenhuma experiência registrada na nuvem.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historico.length,
          itemBuilder: (context, index) {
            final exp = historico[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.bookmark_added, color: Color(0xFF2E7D32)),
                title: Text('${exp.cidade} (${exp.temperatura}°C)'),
                subtitle: Text('Clima: ${exp.clima} | Registrado em: ${exp.data}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF1565C0)),
                      onPressed: () => _dialogEditarExperiencia(exp),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          _userBloc.apagarExperiencia(_usuarioLogado!.uid, exp.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _dialogEditarExperiencia(Experiencia exp) {
    final ctrl = TextEditingController(text: exp.cidade);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Experiência'),
        content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Nome da cidade')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nova = ctrl.text.trim();
              if (nova.isNotEmpty) {
                _userBloc.editarExperiencia(_usuarioLogado!.uid, exp.id, nova);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Experiência atualizada!')));
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5));

  Widget _seletorChips({
    required List<Map<String, String>> opcoes,
    required String selecionado,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: opcoes.map((op) {
        final sel = selecionado == op['value'];
        return GestureDetector(
          onTap: () => onSelect(op['value']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF1565C0) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: sel ? const Color(0xFF1565C0) : Colors.grey.shade300),
            ),
            child: Text(op['label']!,
                style: TextStyle(
                    fontSize: 13,
                    color: sel ? Colors.white : Colors.black87,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _seletorEstado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _estadoSelecionado,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          onChanged: (v) => setState(() => _estadoSelecionado = v!),
          items: WeatherBloc.nomeEstados.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
        ),
      ),
    );
  }
}