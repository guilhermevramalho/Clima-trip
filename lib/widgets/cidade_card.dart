import 'package:flutter/material.dart';
import '../models/cidade.dart';

class CidadeCard extends StatelessWidget {
  final Cidade cidade;
  final bool favoritado;
  final VoidCallback onFavoritoPressed;
  final VoidCallback? onSalvarExperiencia;

  const CidadeCard({
    super.key,
    required this.cidade,
    required this.favoritado,
    required this.onFavoritoPressed,
    this.onSalvarExperiencia,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            cidade.imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(height: 140, color: const Color(0xFF1565C0)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${cidade.nome}, ${cidade.pais}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(favoritado ? Icons.favorite : Icons.favorite_border, color: favoritado ? Colors.red : Colors.grey),
                      onPressed: onFavoritoPressed,
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(cidade.icone, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text('${cidade.temperatura}°C', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                    const SizedBox(width: 12),
                    Text(cidade.descClima.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Divider(height: 16),
                Text('💡 Atividade: ${cidade.atividade}', style: const TextStyle(fontSize: 12)),
                Text('👕 Roupa: ${cidade.roupa}', style: const TextStyle(fontSize: 12)),
                if (onSalvarExperiencia != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                      onPressed: onSalvarExperiencia,
                      icon: const Icon(Icons.bookmark_border, size: 16),
                      label: const Text('Salvar Experiência'),
                    ),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}