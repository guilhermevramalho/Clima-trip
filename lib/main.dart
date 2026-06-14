import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Importação essencial para a checagem web
import 'screens/home_screen.dart';

void main() async {
  // Garante que os componentes do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();
  
  // Só tenta rodar o Firebase se NÃO for no navegador Chrome/Web.
  // Isso evita que a tela fique totalmente branca!
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  
  runApp(const ClimaTrip());
}

class ClimaTrip extends StatelessWidget {
  const ClimaTrip({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaTrip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}