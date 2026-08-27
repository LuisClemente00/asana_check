// Archivo: history_screen.dart

import 'package:flutter/material.dart';
import 'session_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Función auxiliar para formatear la fecha ISO a algo amigable (ej: "20 Jul, 20:55")
  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      final day = dateTime.day;
      final month = months[dateTime.month - 1];
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day $month, $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }

  // Función auxiliar para formatear segundos a texto legible
  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '$minutes min';
    }
    return '$minutes min ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text(
          "Historial de Práctica",
          style: TextStyle(
            color: Color(0xFF2D3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFFFDF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Tarjeta de Racha ---
              FutureBuilder<int>(
                future: SessionStorage.getStreak(),
                builder: (context, snapshot) {
                  final streak = snapshot.data ?? 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🔥', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$streak ${streak == 1 ? 'Día en racha' : 'Días en racha'}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3A3A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "¡Mantén la constancia diaria!",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7A8D8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                "Sesiones Recientes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A3A),
                ),
              ),
              const SizedBox(height: 16),

              // --- Lista de Sesiones usando SessionStorage ---
              FutureBuilder<List<Map<String, dynamic>>>(
                future: SessionStorage.getSessionHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A7C59),
                      ),
                    );
                  }

                  final rawSessions = snapshot.data ?? [];
                  // Invertimos la lista para mostrar la más reciente primero
                  final sessions = rawSessions.reversed.toList();

                  if (sessions.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.self_improvement_rounded,
                            size: 48,
                            color: Color(0xFF7A8D8D),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Aún no has registrado sesiones",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF7A8D8D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final asanaTitle = session['asana'] ?? 'Sesión Libre';
                      final durationSeconds = session['duration'] as int? ?? 0;
                      final dateStr = session['date'] as String? ?? '';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A7C59)
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.self_improvement_rounded,
                                color: Color(0xFF4A7C59),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    asanaTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3A3A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: Color(0xFF7A8D8D),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDuration(durationSeconds),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF7A8D8D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatDate(dateStr),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7A8D8D),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}