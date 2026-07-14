import 'dart:async';
import 'package:flutter/material.dart';
import 'practice_screen.dart';

class CalibrationScreen extends StatefulWidget {
  final String asanaName;

  const CalibrationScreen({super.key, required this.asanaName});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int _countdown = 5;
  bool _isCalibrated = false;
  Timer? _timer;

  // Simulamos que la IA tarda 3 segundos en detectar el cuerpo completo
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isCalibrated = true;
          });
          _startCountdown();
        }
      });
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 1) {
            _countdown--;
          } else {
            _timer?.cancel();
            _goToPractice();
          }
        });
      }
    });
  }

  void _goToPractice() {
    // Reemplazamos la pantalla de calibración por la de práctica interactiva
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PracticeScreen(asanaName: widget.asanaName),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3A3A), // Fondo oscuro para dar sensación de cámara activa
      body: SafeArea(
        child: Column(
          children: [
            // Botón atrás y título
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Calibrando ${widget.asanaName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Área de simulación de Cámara
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isCalibrated ? const Color(0xFF4A7C59) : const Color(0xFFD08C60),
                    width: 3,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Silueta guía
                    Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.accessibility_new_rounded,
                        size: 200,
                        color: _isCalibrated ? const Color(0xFF4A7C59) : Colors.white,
                      ),
                    ),
                    
                    // Estado de calibración
                    if (!_isCalibrated) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD08C60)),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Buscando tu cuerpo...',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Aléjate 2 metros de la cámara',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Cuenta atrás interactiva
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF4A7C59), size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            '¡Cuerpo detectado!',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '$_countdown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Prepárate para la postura',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}