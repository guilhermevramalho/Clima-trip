import 'dart:async';
import '../data/weather_service.dart';
import '../models/cidade.dart';

class FiltroClima {
  final String clima;
  final String estado;
  final double tempMin;
  final double tempMax;

  const FiltroClima({
    this.clima = 'qualquer',
    this.estado = 'todos',
    this.tempMin = 0,
    this.tempMax = 45,
  });
}

class WeatherState {
  final bool buscando;
  final bool carregandoMais;
  final bool buscaFeita;
  final List<Cidade> resultados;
  final List<Map<String, String>> poolRestante;

  const WeatherState({
    this.buscando = false,
    this.carregandoMais = false,
    this.buscaFeita = false,
    this.resultados = const [],
    this.poolRestante = const [],
  });

  WeatherState copyWith({
    bool? buscando,
    bool? carregandoMais,
    bool? buscaFeita,
    List<Cidade>? resultados,
    List<Map<String, String>>? poolRestante,
  }) {
    return WeatherState(
      buscando: buscando ?? this.buscando,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      buscaFeita: buscaFeita ?? this.buscaFeita,
      resultados: resultados ?? this.resultados,
      poolRestante: poolRestante ?? this.poolRestante,
    );
  }
}

class WeatherBloc {
  final WeatherService _weatherService;

  final _controller = StreamController<WeatherState>.broadcast();
  Stream<WeatherState> get stream => _controller.stream;

  WeatherState _state = const WeatherState();

  static const int _porPagina = 5;

  static const Map<String, List<Map<String, String>>> cidadesPorEstado = {
    'SP': [
      {'nome': 'São Paulo',           'query': 'Sao Paulo,BR'},
      {'nome': 'Campinas',            'query': 'Campinas,BR'},
      {'nome': 'Santos',              'query': 'Santos,BR'},
      {'nome': 'Ribeirão Preto',      'query': 'Ribeirao Preto,BR'},
      {'nome': 'São José dos Campos', 'query': 'Sao Jose dos Campos,BR'},
      {'nome': 'Sorocaba',            'query': 'Sorocaba,BR'},
      {'nome': 'Guarujá',             'query': 'Guaruja,BR'},
      {'nome': 'Ilhabela',            'query': 'Ilhabela,BR'},
    ],
    'RJ': [
      {'nome': 'Rio de Janeiro', 'query': 'Rio de Janeiro,BR'},
      {'nome': 'Niterói',        'query': 'Niteroi,BR'},
      {'nome': 'Petrópolis',     'query': 'Petropolis,BR'},
      {'nome': 'Angra dos Reis', 'query': 'Angra dos Reis,BR'},
      {'nome': 'Búzios',         'query': 'Buzios,BR'},
      {'nome': 'Paraty',         'query': 'Paraty,BR'},
      {'nome': 'Cabo Frio',      'query': 'Cabo Frio,BR'},
      {'nome': 'Teresópolis',    'query': 'Teresopolis,BR'},
    ],
    'MG': [
      {'nome': 'Belo Horizonte',  'query': 'Belo Horizonte,BR'},
      {'nome': 'Uberlândia',      'query': 'Uberlandia,BR'},
      {'nome': 'Ouro Preto',      'query': 'Ouro Preto,BR'},
      {'nome': 'Diamantina',      'query': 'Diamantina,BR'},
      {'nome': 'Tiradentes',      'query': 'Tiradentes,BR'},
      {'nome': 'Poços de Caldas', 'query': 'Pocos de Caldas,BR'},
      {'nome': 'São João del-Rei','query': 'Sao Joao del Rei,BR'},
      {'nome': 'Araxá',           'query': 'Araxa,BR'},
    ],
    'SC': [
      {'nome': 'Florianópolis',       'query': 'Florianopolis,BR'},
      {'nome': 'Blumenau',            'query': 'Blumenau,BR'},
      {'nome': 'Joinville',           'query': 'Joinville,BR'},
      {'nome': 'Balneário Camboriú',  'query': 'Balneario Camboriu,BR'},
      {'nome': 'Bombinhas',           'query': 'Bombinhas,BR'},
      {'nome': 'Chapecó',             'query': 'Chapeco,BR'},
      {'nome': 'Laguna',              'query': 'Laguna,BR'},
      {'nome': 'São Francisco do Sul','query': 'Sao Francisco do Sul,BR'},
    ],
    'RS': [
      {'nome': 'Porto Alegre',    'query': 'Porto Alegre,BR'},
      {'nome': 'Gramado',         'query': 'Gramado,BR'},
      {'nome': 'Canela',          'query': 'Canela,BR'},
      {'nome': 'Bento Gonçalves', 'query': 'Bento Goncalves,BR'},
      {'nome': 'Torres',          'query': 'Torres,BR'},
      {'nome': 'Pelotas',         'query': 'Pelotas,BR'},
      {'nome': 'Caxias do Sul',   'query': 'Caxias do Sul,BR'},
      {'nome': 'Santa Maria',     'query': 'Santa Maria,BR'},
    ],
    'PR': [
      {'nome': 'Curitiba',      'query': 'Curitiba,BR'},
      {'nome': 'Foz do Iguaçu', 'query': 'Foz do Iguacu,BR'},
      {'nome': 'Londrina',      'query': 'Londrina,BR'},
      {'nome': 'Maringá',       'query': 'Maringa,BR'},
      {'nome': 'Morretes',      'query': 'Morretes,BR'},
      {'nome': 'Guaratuba',     'query': 'Guaratuba,BR'},
      {'nome': 'Antonina',      'query': 'Antonina,BR'},
      {'nome': 'Paranaguá',     'query': 'Paranagua,BR'},
    ],
    'BA': [
      {'nome': 'Salvador',           'query': 'Salvador,BR'},
      {'nome': 'Porto Seguro',       'query': 'Porto Seguro,BR'},
      {'nome': 'Ilhéus',             'query': 'Ilheus,BR'},
      {'nome': 'Morro de São Paulo',  'query': 'Morro de Sao Paulo,BR'},
      {'nome': 'Lençóis',            'query': 'Lencois,BR'},
      {'nome': 'Camaçari',           'query': 'Camacari,BR'},
      {'nome': 'Itacaré',            'query': 'Itacare,BR'},
      {'nome': 'Valença',            'query': 'Valenca,BR'},
    ],
    'CE': [
      {'nome': 'Fortaleza',         'query': 'Fortaleza,BR'},
      {'nome': 'Jericoacoara',      'query': 'Jericoacoara,BR'},
      {'nome': 'Canoa Quebrada',    'query': 'Canoa Quebrada,BR'},
      {'nome': 'Cumbuco',           'query': 'Cumbuco,BR'},
      {'nome': 'Juazeiro do Norte', 'query': 'Juazeiro do Norte,BR'},
      {'nome': 'Sobral',            'query': 'Sobral,BR'},
      {'nome': 'Quixadá',           'query': 'Quixada,BR'},
      {'nome': 'Caucaia',           'query': 'Caucaia,BR'},
    ],
    'AM': [
      {'nome': 'Manaus',      'query': 'Manaus,BR'},
      {'nome': 'Parintins',   'query': 'Parintins,BR'},
      {'nome': 'Itacoatiara', 'query': 'Itacoatiara,BR'},
      {'nome': 'Tefé',        'query': 'Tefe,BR'},
      {'nome': 'Barcelos',    'query': 'Barcelos,BR'},
      {'nome': 'Coari',       'query': 'Coari,BR'},
      {'nome': 'Tabatinga',   'query': 'Tabatinga,BR'},
      {'nome': 'Eirunepé',    'query': 'Eirunepe,BR'},
    ],
    'PE': [
      {'nome': 'Recife',              'query': 'Recife,BR'},
      {'nome': 'Olinda',              'query': 'Olinda,BR'},
      {'nome': 'Caruaru',             'query': 'Caruaru,BR'},
      {'nome': 'Porto de Galinhas',   'query': 'Ipojuca,BR'},
      {'nome': 'Petrolina',           'query': 'Petrolina,BR'},
      {'nome': 'Gravatá',             'query': 'Gravata,BR'},
      {'nome': 'Triunfo',             'query': 'Triunfo,BR'},
      {'nome': 'Fernando de Noronha', 'query': 'Fernando de Noronha,BR'},
    ],
    'INT': [
      {'nome': 'Buenos Aires',    'query': 'Buenos Aires,AR'},
      {'nome': 'London',          'query': 'London,GB'},
      {'nome': 'Paris',           'query': 'Paris,FR'},
      {'nome': 'Tokyo',           'query': 'Tokyo,JP'},
      {'nome': 'New York',        'query': 'New York,US'},
      {'nome': 'Lisboa',          'query': 'Lisbon,PT'},
      {'nome': 'Barcelona',       'query': 'Barcelona,ES'},
      {'nome': 'Cancún',          'query': 'Cancun,MX'},
      {'nome': 'Miami',           'query': 'Miami,US'},
      {'nome': 'Cidade do México','query': 'Mexico City,MX'},
    ],
  };

  static const Map<String, String> nomeEstados = {
    'todos': 'Todos os estados',
    'SP': 'São Paulo',
    'RJ': 'Rio de Janeiro',
    'MG': 'Minas Gerais',
    'SC': 'Santa Catarina',
    'RS': 'Rio Grande do Sul',
    'PR': 'Paraná',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'AM': 'Amazonas',
    'PE': 'Pernambuco',
    'INT': 'Internacionais',
  };

  WeatherBloc({required WeatherService weatherService})
      : _weatherService = weatherService;

  void _emit(WeatherState state) {
    _state = state;
    _controller.add(state);
  }

  List<Map<String, String>> _montarPool(String estado) {
    if (estado == 'todos') {
      return cidadesPorEstado.entries
          .where((e) => e.key != 'INT')
          .expand((e) => e.value)
          .toList();
    }
    return List<Map<String, String>>.from(cidadesPorEstado[estado] ?? []);
  }

  bool _filtroOk(Cidade cidade, FiltroClima filtro) {
    if (filtro.clima != 'qualquer') {
      if (filtro.clima == 'calor'     && cidade.temperatura < 26)  return false;
      if (filtro.clima == 'agradavel' && (cidade.temperatura < 15 || cidade.temperatura >= 26)) return false;
      if (filtro.clima == 'frio'      && cidade.temperatura >= 15) return false;
      if (filtro.clima == 'chuva'     && cidade.clima != 'chuvoso') return false;
    }
    if (cidade.temperatura < filtro.tempMin || cidade.temperatura > filtro.tempMax) return false;
    return true;
  }

  Future<List<Cidade>> _buscarProximas(
    List<Map<String, String>> pool,
    int limite,
    FiltroClima filtro,
  ) async {
    final List<Cidade> encontradas = [];
    final List<Map<String, String>> consumidas = [];

    for (final c in pool) {
      if (encontradas.length >= limite) break;
      consumidas.add(c);
      try {
        final cidade = await _weatherService.buscarDadosClima(c['query']!);
        if (_filtroOk(cidade, filtro)) encontradas.add(cidade);
      } catch (_) {}
    }
    pool.removeWhere((c) => consumidas.contains(c));
    return encontradas;
  }

  Future<void> buscarPorFiltros(FiltroClima filtro) async {
    final pool = _montarPool(filtro.estado);
    _emit(_state.copyWith(
      buscando: true,
      resultados: [],
      buscaFeita: false,
      poolRestante: pool,
    ));

    final encontradas = await _buscarProximas(pool, _porPagina, filtro);
    _emit(_state.copyWith(
      buscando: false,
      buscaFeita: true,
      resultados: encontradas,
      poolRestante: pool,
    ));
  }

  Future<void> carregarMais(FiltroClima filtro) async {
    if (_state.poolRestante.isEmpty || _state.carregandoMais) return;

    final pool = List<Map<String, String>>.from(_state.poolRestante);
    _emit(_state.copyWith(carregandoMais: true));

    final novas = await _buscarProximas(pool, _porPagina, filtro);
    _emit(_state.copyWith(
      carregandoMais: false,
      resultados: [..._state.resultados, ...novas],
      poolRestante: pool,
    ));
  }

  void dispose() {
    _controller.close();
  }
}