// Archivo: history_screen.dart

import 'package:flutter/material.dart';
import 'session_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    final history = await SessionStorage.getSessionHistory();
    final streak = await SessionStorage.getStreak();

    if (!mounted) return;

    setState(() {
      _history = history.reversed.toList(); // Mostramos las más recientes primero
      _streak = streak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFDF),
        elevation: 0,
        title: const Text(
          "Historial de Práctica",
          style: TextStyle(color: Color(0xFF2D3A3A), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TARJETA DE RACHA DE DÍAS ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A7C59).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('🔥', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$_streak ${_streak == 1 ? 'Día' : 'Días'} en racha",
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Sesiones Recientes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- LISTA DE HISTORIAL ---
                  Expanded(
                    child: _history.isEmpty
                        ? const Center(
                            child: Text(
                              "Aún no has completado ninguna sesión.\n¡Inicia tu primera práctica!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF7A8D8D)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              final asana = item['asana'] ?? 'Sesión Libre';
                              final seconds = item['duration'] ?? 0;
                              final date = item['date'] ?? '';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: const Color(0xFF4A7C59).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFEAF4EC),
                                    child: Icon(
                                      Icons.self_improvement_rounded,
                                      color: Color(0xFF4A7C59),
                                    ),
                                  ),
                                  title: Text(
                                    asana,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3A3A),
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Duración: ${seconds}s",
                                    style: const TextStyle(color: Color(0xFF7A8D8D)),
                                  ),
                                  trailing: Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A8D8D),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}