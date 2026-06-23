import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cidade.dart';

class WeatherService {
  final String _apiKey = '308537ba2da804f94111afbe6de6428e';

  String _obterLinkImagem(String climaPrincipal) {
    switch (climaPrincipal.toLowerCase()) {
      case 'clear':
        return 'https://images.unsplash.com/photo-1504386106283-7f3e84ddd13e?w=600';
      case 'clouds':
        return 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=600';
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?w=600';
      default:
        return 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?w=600';
    }
  }

  Future<Cidade> buscarDadosClima(String nomeCidade) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$nomeCidade&appid=$_apiKey&units=metric&lang=pt_br');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final principal = json['weather'][0]['main'];
      final temp = (json['main']['temp'] as num).round();

      String atividade = 'Fazer turismo urbano e visitar museus locais';
      String roupa = 'Roupas casuais confortáveis';
      String tagClima = 'agradavel';

      if (temp >= 26) {
        atividade = 'Aproveitar praias, piscinas e parques ao ar livre';
        roupa = 'Roupas leves, óculos de sol e protetor solar';
        tagClima = 'ensolarado';
      } else if (temp < 15) {
        atividade = 'Visitar cafés aconchegantes e espaços cobertos';
        roupa = 'Casaco reforçado, calça comprida e cachecol';
        tagClima = 'frio';
      }

      return Cidade(
        nome: json['name'],
        pais: json['sys']['country'],
        temperatura: temp,
        clima: tagClima,
        descClima: json['weather'][0]['description'],
        atividade: atividade,
        roupa: roupa,
        icone: temp >= 26 ? '☀️' : (temp < 15 ? '❄️' : '⛅'),
        imageUrl: _obterLinkImagem(principal),
      );
    } else {
      throw Exception('Cidade não encontrada na base de dados.');
    }
  }
}