import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  final String asanaName;
  final int score;

  const ProgressScreen({
    super.key,
    required this.asanaName,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Icono de Éxito / Logro estilo Zen
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7C59).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded, // Un icono de loto/bienestar zen
                  color: Color(0xFF4A7C59),
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),

              // Mensaje de felicitación
              const Text(
                '¡Práctica Completada!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A3A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has finalizado tu sesión de $asanaName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8D8D),
                ),
              ),
              const SizedBox(height: 40),

              // Tarjeta de Estadísticas de la Sesión
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D3A3A).withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Columna Precisión
                    Column(
                      children: [
                        const Text(
                          'PRECISIÓN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A8D8D),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$score%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                      ],
                    ),
                    // Línea divisoria central
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFE0E5E5),
                    ),
                    // Columna Tiempo
                    Column(
                      children: [
                        const Text(
                          'TIEMPO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A8D8D),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '0:30',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3A3A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // Botón de Volver al Inicio
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3A3A), // Botón oscuro zen
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Volvemos a la pantalla de inicio (Lobby) limpiando la pila
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Volver al Lobby Zen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}