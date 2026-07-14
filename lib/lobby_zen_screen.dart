import 'package:flutter/material.dart';
import 'calibration_screen.dart';

class LobbyZenScreen extends StatelessWidget {
  const LobbyZenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Cabecera Zen
              const Text(
                'Namasté, Yogui',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A3A), // Gris verdoso oscuro
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Qué asana practicamos hoy?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8D8D),
                ),
              ),
              const SizedBox(height: 32),
              // Listado de Posturas
              Expanded(
                child: ListView(
                  children: [
                    _buildAsanaCard(
                      title: 'El Árbol',
                      sanskrit: 'Vrikshasana',
                      subtitle: 'Equilibrio • 5 min • Principiante',
                      icon: Icons.park_outlined,
                      onTap: () => _startCalibration(context, 'El Árbol'), // <-- Cambiado aquí
                    ),
                    const SizedBox(height: 16),
                    _buildAsanaCard(
                      title: 'El Guerrero II',
                      sanskrit: 'Virabhadrasana II',
                      subtitle: 'Fuerza • 8 min • Intermedio',
                      icon: Icons.accessibility_new_outlined,
                      onTap: () => _startCalibration(context, 'El Guerrero II'), // <-- Cambiado aquí
                    ),
                    const SizedBox(height: 16),
                    _buildAsanaCard(
                      title: 'La Plancha',
                      sanskrit: 'Phalakasana',
                      subtitle: 'Core • 5 min • Intermedio',
                      icon: Icons.horizontal_rule_rounded,
                      onTap: () => _startCalibration(context, 'La Plancha'), // <-- Cambiado aquí
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAsanaCard({
    required String title,
    required String sanskrit,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D3A3A).withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono con fondo circular suave verde
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.1), // Verde translúcido
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4A7C59), // Verde hoja de palmera
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            // Textos descriptivos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  Text(
                    sanskrit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF7A8D8D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8D8D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF7A8D8D),
            ),
          ],
        ),
      ),
    );
  }

  void _startCalibration(BuildContext context, String asanaName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalibrationScreen(asanaName: asanaName),
      ),
    );
  }
}