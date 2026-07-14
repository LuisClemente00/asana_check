import 'dart:async';
import 'package:flutter/material.dart';
import 'progress_screen.dart';

class PracticeScreen extends StatefulWidget {
  final String asanaName;

  const PracticeScreen({super.key, required this.asanaName});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  double _precision = 75.0;
  String _feedbackText = "Alineando postura...";
  Color _skeletonColor = const Color(0xFFD08C60); // Terracota inicial (corrigiendo)
  Timer? _simulationTimer;
  int _secondsLeft = 30; // Sesión de prueba de 30 segundos

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  // Simulamos el comportamiento de la IA a lo largo del tiempo
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          
          // Fase 1 (Segundos 30-25): El usuario se está colocando
          if (_secondsLeft > 25) {
            _precision = 72.0 + (_secondsLeft % 3);
            _feedbackText = "Sube un poco más los brazos...";
            _skeletonColor = const Color(0xFFD08C60); // Terracota
          } 
          // Fase 2 (Segundos 25-15): Corrección exitosa
          else if (_secondsLeft > 15) {
            _precision = 88.0 + (_secondsLeft % 4);
            _feedbackText = "¡Excelente! Mantén la espalda recta";
            _skeletonColor = const Color(0xFF4A7C59); // Verde Zen
          } 
          // Fase 3 (Segundos 15-5): Pierde un poco el equilibrio
          else if (_secondsLeft > 5) {
            _precision = 79.0 - (_secondsLeft % 2);
            _feedbackText = "Cuidado con la rodilla, no la dejes caer";
            _skeletonColor = const Color(0xFFD08C60); // Terracota
          } 
          // Fase 4 (Últimos segundos): Recupera la postura
          else {
            _precision = 94.0;
            _feedbackText = "Postura perfecta. Aguanta el final...";
            _skeletonColor = const Color(0xFF4A7C59); // Verde Zen
          }
        } else {
          _simulationTimer?.cancel();
          _finishPractice();
        }
      });
    });
  }

  void _finishPractice() {
    // Vamos a la pantalla de progreso pasando el score final simulado
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProgressScreen(
          asanaName: widget.asanaName,
          score: _precision.toInt(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3A3A),
      body: Stack(
        children: [
          // 1. Simulación del visor de la cámara (Fondo gris oscuro interactivo)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF1F2828),
              child: Center(
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 2. Pintado del Esqueleto de la IA (Simulado en pantalla)
          Positioned.fill(
            child: SafeArea(
              child: CustomPaint(
                painter: SkeletonPainter(color: _skeletonColor, precision: _precision),
              ),
            ),
          ),

          // 3. Interfaz de Usuario flotante estilo "Bali Zen"
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fila Superior: Botón salir, Título y Temporizador
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '0:${_secondsLeft.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Fila Inferior: Panel de Feedback de la IA en tiempo real
                  Column(
                    children: [
                      // Indicador de precisión flotante circular
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: _skeletonColor, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_precision.toInt()}%',
                              style: TextStyle(
                                color: _skeletonColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'SCORE',
                              style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tarjeta de Feedback hablado/escrito
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _precision >= 85 ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              color: _skeletonColor,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.asanaName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF2D3A3A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _feedbackText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4A5555),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para dibujar líneas de articulaciones en la pantalla
class SkeletonPainter extends CustomPainter {
  final Color color;
  final double precision;

  SkeletonPainter({required this.color, required this.precision});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Coordenadas simuladas de un yogui en pantalla
    final head = Offset(size.width * 0.5, size.height * 0.3);
    final neck = Offset(size.width * 0.5, size.height * 0.38);
    final leftShoulder = Offset(size.width * 0.38, size.height * 0.4);
    final rightShoulder = Offset(size.width * 0.62, size.height * 0.4);
    
    // Si la precisión es baja, simulamos que los brazos están caídos/desalineados
    final armFactor = precision < 85 ? 0.55 : 0.4;
    final leftElbow = Offset(size.width * 0.3, size.height * armFactor);
    final leftHand = Offset(size.width * 0.22, size.height * (armFactor - 0.1));
    final rightElbow = Offset(size.width * 0.7, size.height * armFactor);
    final rightHand = Offset(size.width * 0.78, size.height * (armFactor - 0.1));

    final spine = Offset(size.width * 0.5, size.height * 0.55);
    final leftHip = Offset(size.width * 0.42, size.height * 0.6);
    final rightHip = Offset(size.width * 0.58, size.height * 0.6);
    
    final leftKnee = Offset(size.width * 0.42, size.height * 0.73);
    final leftFoot = Offset(size.width * 0.42, size.height * 0.85);
    final rightKnee = Offset(size.width * 0.58, size.height * 0.73);
    final rightFoot = Offset(size.width * 0.58, size.height * 0.85);

    // Dibujar líneas del esqueleto
    canvas.drawLine(head, neck, paint);
    canvas.drawLine(leftShoulder, rightShoulder, paint);
    canvas.drawLine(neck, spine, paint);
    canvas.drawLine(leftShoulder, leftElbow, paint);
    canvas.drawLine(leftElbow, leftHand, paint);
    canvas.drawLine(rightShoulder, rightElbow, paint);
    canvas.drawLine(rightElbow, rightHand, paint);
    canvas.drawLine(spine, leftHip, paint);
    canvas.drawLine(spine, rightHip, paint);
    canvas.drawLine(leftHip, leftKnee, paint);
    canvas.drawLine(leftKnee, leftFoot, paint);
    canvas.drawLine(rightHip, rightKnee, paint);
    canvas.drawLine(rightKnee, rightFoot, paint);

    // Dibujar puntos en las articulaciones clave para que parezca una IA real
    var joints = [head, neck, leftShoulder, rightShoulder, leftElbow, leftHand, rightElbow, rightHand, leftHip, rightHip, leftKnee, leftFoot, rightKnee, rightFoot];
    for (var joint in joints) {
      canvas.drawCircle(joint, 6.0, jointPaint);
      canvas.drawCircle(joint, 8.0, Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.precision != precision;
  }
}