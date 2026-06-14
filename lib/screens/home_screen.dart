import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/weather_bloc.dart';
import '../blocs/dados_usuario_bloc.dart';
import '../models/cidade.dart';
import '../widgets/cidade_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _abaAtual = 0;
  final AuthBloc _authBloc = AuthBloc();
  final WeatherBloc _weatherBloc = WeatherBloc();
  final DadosUsuarioBloc _userBloc = DadosUsuarioBloc();
  final _buscaCtrl = TextEditingController();

  User? _usuarioLogado;

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
    _weatherBloc.dispose();
    _userBloc.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ClimaTrip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
            Text(
              _usuarioLogado != null
                  ? 'Olá, ${_usuarioLogado!.email!.split('@').first}! 🌟'
                  : 'Descubra seu próximo destino',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            )
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen(authBloc: _authBloc)),
                  ),
                )
        ],
      ),
      body: IndexedStack(
        index: _abaAtual,
        children: [
          _abaDestaques(),
          _abaBuscarRealTime(),
          _abaFavoritosFirestore(),
          _abaHistoricoFirestore(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _abaAtual = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
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
        imageUrl: 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=600',
      ),
      Cidade(
        nome: 'Gramado', pais: 'BR', temperatura: 12, clima: 'frio',
        descClima: 'Nevoeiro encorpado', atividade: 'Visitar cafés e comer fondue',
        roupa: 'Casaco pesado e cachecol', icone: '❄️',
        imageUrl: 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?w=600',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Destinos Recomendados hoje:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...cidadesDestaque.map((c) => CidadeCard(cidade: c, favoritado: false, onFavoritoPressed: () {})),
      ],
    );
  }

  Widget _abaBuscarRealTime() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _buscaCtrl,
            decoration: InputDecoration(
              hintText: 'Digite o nome da cidade (ex: Paris, Cairo)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _weatherBloc.pesquisarClima(_buscaCtrl.text.trim()),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<Cidade?>(
              stream: _weatherBloc.stream,
              builder: (context, weatherSnap) {
                if (weatherSnap.hasError) {
                  return Center(child: Text('${weatherSnap.error}', style: const TextStyle(color: Colors.red)));
                }
                if (weatherSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!weatherSnap.hasData) {
                  return const Center(child: Text('Pesquise um destino para conectar à API.'));
                }

                final cidadeObtida = weatherSnap.data!;

                if (_usuarioLogado == null) {
                  return ListView(
                    children: [
                      CidadeCard(cidade: cidadeObtida, favoritado: false, onFavoritoPressed: _alertaLogin),
                    ],
                  );
                }

                return StreamBuilder<List<Cidade>>(
                  stream: _userBloc.streamFavoritosDoUsuario(_usuarioLogado!.uid),
                  builder: (context, favSnap) {
                    final listaFavs = favSnap.data ?? [];
                    final jaFavoritado = listaFavs.any((e) => e.nome == cidadeObtida.nome);

                    return ListView(
                      children: [
                        CidadeCard(
                          cidade: cidadeObtida,
                          favoritado: jaFavoritado,
                          onFavoritoPressed: () {
                            _userBloc.alternarFavorito(_usuarioLogado!.uid, cidadeObtida, jaFavoritado);
                          },
                          onSalvarExperiencia: () {
                            _userBloc.registrarNovaExperiencia(_usuarioLogado!.uid, cidadeObtida);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Experiência salva com sucesso no Firestore!')),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        if (favoritos.isEmpty) return const Center(child: Text('Nenhum destino favoritado ainda.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoritos.length,
          itemBuilder: (context, index) {
            final item = favoritos[index];
            return CidadeCard(
              cidade: item,
              favoritado: true,
              onFavoritoPressed: () => _userBloc.alternarFavorito(_usuarioLogado!.uid, item, true),
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
        if (historico.isEmpty) return const Center(child: Text('Nenhuma experiência registrada na nuvem.'));

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
                      onPressed: () => _userBloc.apagarExperiencia(_usuarioLogado!.uid, exp.id),
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
          decoration: const InputDecoration(labelText: 'Nome da cidade'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final novaCidade = ctrl.text.trim();
              if (novaCidade.isNotEmpty) {
                _userBloc.editarExperiencia(_usuarioLogado!.uid, exp.id, novaCidade);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Experiência atualizada!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _alertaLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ação restrita! Por favor, faça login primeiro.')),
    );
  }
}