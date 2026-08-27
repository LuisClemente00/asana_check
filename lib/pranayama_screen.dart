// Archivo: pranayama_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gamification_service.dart';

class PranayamaTechnique {
  final String title;
  final String subtitle;
  final String description;
  final String howToBreathe; // Explicación técnica de ejecución
  final int inhale;
  final int holdIn;
  final int exhale;
  final int holdOut;
  final Color color;

  PranayamaTechnique({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.howToBreathe,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
    required this.color,
  });
}

class PranayamaScreen extends StatefulWidget {
  const PranayamaScreen({super.key});

  @override
  State<PranayamaScreen> createState() => _PranayamaScreenState();
}

class _PranayamaScreenState extends State<PranayamaScreen>
    with SingleTickerProviderStateMixin {
  final List<PranayamaTechnique> _techniques = [
    PranayamaTechnique(
      title: "Respiración Cuadrada",
      subtitle: "Sama Vritti • Calma & Enfoque",
      description: "Equilibra el sistema nervioso y calma la mente agitada.",
      howToBreathe:
          "Inhala por la nariz expandiendo el abdomen. Retén el aire manteniendo la garganta relajada (sin bloquear con fuerza). Exhala lentamente por la nariz contrayendo el ombligo. Mantén los pulmones vacíos antes de la siguiente inhalación.",
      inhale: 4,
      holdIn: 4,
      exhale: 4,
      holdOut: 4,
      color: const Color(0xFF4A7C59),
    ),
    PranayamaTechnique(
      title: "Respiración 4-7-8",
      subtitle: "Relax Profundo • Anti-Estrés",
      description: "Un sedante natural potente para el estrés y el insomnio.",
      howToBreathe:
          "Coloca la punta de la lengua en el paladar, justo detrás de los dientes superiores. Inhala silenciosamente por la nariz durante 4s. Retén el aire durante 7s. Exhala ruidosamente por la boca haciendo un sonido de 'soplido' durante 8s.",
      inhale: 4,
      holdIn: 7,
      exhale: 8,
      holdOut: 0,
      color: const Color(0xFF2D5AC8),
    ),
    PranayamaTechnique(
      title: "Respiración Energizante",
      subtitle: "Vitalidad • Fuego Interno",
      description: "Limpia las vías respiratorias y despierta la mente por la mañana.",
      howToBreathe:
          "Inhala de manera activa y profunda expandiendo el tórax. Retén solo 2 segundos para concentrar la energía. Exhala de forma enérgica por la nariz activando la faja abdominal.",
      inhale: 3,
      holdIn: 2,
      exhale: 3,
      holdOut: 0,
      color: Colors.deepOrange,
    ),
  ];

  late PranayamaTechnique _selectedTechnique;
  int _selectedTargetMinutes = 3; // Límite por defecto: 3 minutos

  bool _isActive = false;
  String _currentPhase = "Prepara tu postura";
  int _phaseSecondsLeft = 0;
  int _totalSecondsRemaining = 0;

  Timer? _phaseTimer;
  Timer? _globalTimer;

  // Animación del Orbe
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTechnique = _techniques[0];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _globalTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startBreathingSession() {
    setState(() {
      _isActive = true;
      _totalSecondsRemaining = _selectedTargetMinutes * 60;
    });

    // Temporizador límite global
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      setState(() {
        _totalSecondsRemaining--;
      });

      if (_totalSecondsRemaining <= 0) {
        timer.cancel();
        _finishSessionAndReward(completedNormally: true);
      }
    });

    _runBreathingCycle();
  }

  void _stopBreathingSession() {
    _phaseTimer?.cancel();
    _globalTimer?.cancel();
    _animController.stop();
    setState(() {
      _isActive = false;
      _currentPhase = "Prepara tu postura";
      _phaseSecondsLeft = 0;
      _totalSecondsRemaining = 0;
    });
  }

  void _runBreathingCycle() async {
    if (!_isActive) return;

    final tech = _selectedTechnique;

    // 1. INHALAR
    await _executePhase(
      phaseName: "INHALA POR LA NARIZ",
      duration: tech.inhale,
      animAction: () {
        _animController.duration = Duration(seconds: tech.inhale);
        _animController.forward(from: 0.0);
      },
    );

    if (!_isActive) return;

    // 2. RETENER CON AIRE
    if (tech.holdIn > 0) {
      await _executePhase(
        phaseName: "RETÉN EL AIRE",
        duration: tech.holdIn,
        animAction: () {},
      );
    }

    if (!_isActive) return;

    // 3. EXHALAR
    await _executePhase(
      phaseName: tech.title == "Respiración 4-7-8"
          ? "EXHALA POR LA BOCA"
          : "EXHALA LENTAMENTE",
      duration: tech.exhale,
      animAction: () {
        _animController.duration = Duration(seconds: tech.exhale);
        _animController.reverse(from: 1.0);
      },
    );

    if (!_isActive) return;

    // 4. RETENER SIN AIRE
    if (tech.holdOut > 0) {
      await _executePhase(
        phaseName: "MANTÉN EN VACÍO",
        duration: tech.holdOut,
        animAction: () {},
      );
    }

    // Repetir ciclo si aún queda tiempo global
    if (_isActive && _totalSecondsRemaining > 0) {
      _runBreathingCycle();
    }
  }

  Future<void> _executePhase({
    required String phaseName,
    required int duration,
    required VoidCallback animAction,
  }) async {
    if (!_isActive) return;

    HapticFeedback.lightImpact();
    setState(() {
      _currentPhase = phaseName;
      _phaseSecondsLeft = duration;
    });

    animAction();

    final completer = Completer<void>();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isActive) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }

      setState(() {
        _phaseSecondsLeft--;
      });

      if (_phaseSecondsLeft <= 0) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  void _finishSessionAndReward({bool completedNormally = false}) async {
    _stopBreathingSession();

    if (completedNormally) {
      final xpGained = _selectedTargetMinutes * 15; // 15 XP por minuto
      await GamificationService.addXP(xpGained);

      if (mounted) {
        _showSuccessDialog(xpGained);
      }
    }
  }

  void _showHowToBreatheDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFDF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: _selectedTechnique.color),
                  const SizedBox(width: 10),
                  Text(
                    "¿Cómo ejecutar la técnica?",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _selectedTechnique.howToBreathe,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF4A5555),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTechnique.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Entendido", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(int xpGained) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🧘‍♀️ ¡Sesión Completada!"),
        content: Text(
          "Has mantenido la presencia durante $_selectedTargetMinutes minutos.\n\n+ $xpGained XP añadidos a tu perfil.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          )
        ],
      ),
    );
  }

  String _formatTotalRemainingTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text(
          "Santuario de Pranayama",
          style: TextStyle(
            color: Color(0xFF2D3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showHowToBreatheDialog,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Selector de Técnicas
            if (!_isActive)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _techniques.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final tech = _techniques[index];
                    final isSelected = tech == _selectedTechnique;

                    return ChoiceChip(
                      label: Text(
                        tech.title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF2D3A3A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: tech.color,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTechnique = tech;
                          });
                        }
                      },
                    );
                  },
                ),
              ),

            // Selector de Límite de Tiempo (Si no está activo)
            if (!_isActive) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Duración: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...[1, 3, 5, 10].map((mins) {
                    final isSelected = _selectedTargetMinutes == mins;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text("$mins min"),
                        selected: isSelected,
                        selectedColor: _selectedTechnique.color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedTargetMinutes = mins);
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],

            // Tiempo Restante Global (Si está activo)
            if (_isActive) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF7A8D8D)),
                    const SizedBox(width: 6),
                    Text(
                      "Tiempo restante: ${_formatTotalRemainingTime(_totalSecondsRemaining)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3A3A),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // --- ORBE ANIMADO DE RESPIRACIÓN ---
            Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final scale = _isActive ? _scaleAnimation.value : 0.6;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Aura exterior
                      Container(
                        width: 260 * scale,
                        height: 260 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedTechnique.color
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      // Orbe principal
                      Container(
                        width: 180 * scale,
                        height: 180 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _selectedTechnique.color,
                              _selectedTechnique.color.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedTechnique.color
                                  .withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Contador en pantalla
                      if (_isActive)
                        Text(
                          "$_phaseSecondsLeft",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Texto de fase actual
            Text(
              _currentPhase,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _selectedTechnique.color,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            // Botón rápido para abrir las instrucciones
            InkWell(
              onTap: _showHowToBreatheDialog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ver instrucciones de técnica",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A8D8D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 14, color: Color(0xFF7A8D8D)),
                ],
              ),
            ),

            const Spacer(),

            // Botón de control
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive
                        ? Colors.redAccent
                        : _selectedTechnique.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_isActive) {
                      _stopBreathingSession();
                    } else {
                      _startBreathingSession();
                    }
                  },
                  child: Text(
                    _isActive ? "Detener Práctica" : "Comenzar ($_selectedTargetMinutes min)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}