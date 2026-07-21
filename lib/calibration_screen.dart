import 'package:flutter/material.dart';
import 'pose_detector_screen.dart';

class CalibrationScreen extends StatefulWidget {
  final String asanaName;

  const CalibrationScreen({super.key, required this.asanaName});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Coloca tu teléfono',
      'description': 'Apoya tu móvil en posición vertical a la altura de la cintura o el suelo, inclinado ligeramente hacia arriba.',
      'icon': Icons.phone_android_rounded,
    },
    {
      'title': 'Aléjate 2 metros',
      'description': 'Da unos pasos hacia atrás. Necesitamos una distancia de unos 2 metros para capturar todos tus movimientos.',
      'icon': Icons.directions_walk_rounded,
    },
    {
      'title': 'Cuerpo completo en pantalla',
      'description': 'Asegúrate de que la cámara te vea de la cabeza a los pies para que la IA de SpainToBali funcione de forma precisa.',
      'icon': Icons.accessibility_new_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF), // Tu color crema suave corporativo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3A3A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Título superior
              Text(
                "Preparando ${widget.asanaName}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A3A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sigue estos 3 sencillos pasos para calibrar tu IA",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF7A8D8D)),
              ),
              const SizedBox(height: 40),

              // Ilustración / Icono del paso actual
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey<int>(_currentStep),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A7C59).withValues(alpha: 0.1), // Solucionado: withValues en lugar de withOpacity
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'],
                        size: 100,
                        color: const Color(0xFF4A7C59), // Verde Zen
                      ),
                    ),
                  ),
                ),
              ),

              // Textos del paso actual
              Column(
                key: ValueKey<int>(_currentStep + 10), // Forzar animación
                children: [
                  Text(
                    "Paso ${_currentStep + 1}: ${step['title']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      step['description'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7A8D8D),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Indicador de puntos (Dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentStep == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentStep == index ? const Color(0xFF2D5AC8) : Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Atrás (Oculto en el primer paso)
                  _currentStep > 0
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          child: const Text(
                            "Anterior",
                            style: TextStyle(color: Color(0xFF7A8D8D), fontSize: 16),
                          ),
                        )
                      : const SizedBox(width: 80),

                  // Botón Siguiente / Empezar
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5AC8), // Tu azul SpainToBali
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      if (_currentStep < _steps.length - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        // Navegamos a la pantalla del detector de poses
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoseDetectorScreen(asanaName: widget.asanaName),
                          ),
                        );

                        // Solucionado: Verificación de seguridad 'mounted' antes de usar BuildContext tras el await
                        if (!mounted) return;

                        // Si se completó la asana en el detector, devolvemos el resultado al Lobby
                        if (completed == true) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    child: Text(
                      _currentStep == _steps.length - 1 ? "¡Comenzar!" : "Siguiente",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}