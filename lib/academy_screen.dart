// Archivo: academy_screen.dart (Versión Completa)

import 'package:flutter/material.dart';
import 'learning_path_model.dart';
import 'academy_progress_service.dart';
import 'lesson_detail_screen.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  Set<String> _completedLessons = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await AcademyProgressService.getCompletedLessons();
    if (mounted) {
      setState(() {
        _completedLessons = completed;
        _isLoading = false;
      });
    }
  }

  double _calculateProgress() {
    int totalLessons = academyModules.expand((m) => m.lessons).length;
    return totalLessons == 0 ? 0 : _completedLessons.length / totalLessons;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text("Ruta del Maestro Yoga", style: TextStyle(color: Color(0xFF2D3A3A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header de Progreso
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF4A7C59), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      const Text("Tu progreso global", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text("${_completedLessons.length} de ${academyModules.expand((m) => m.lessons).length} lecciones", 
                           style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ...academyModules.map((module) => _buildModuleSection(module)),
              ],
            ),
    );
  }

  Widget _buildModuleSection(Module module) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(module.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
      const SizedBox(height: 4),
      Text(module.description, style: const TextStyle(fontSize: 13, color: Color(0xFF7A8D8D))),
      const SizedBox(height: 16),
      ...List.generate(module.lessons.length, (index) {
        final lesson = module.lessons[index];
        final isCompleted = _completedLessons.contains(lesson.id);
        
        // Lógica de desbloqueo secuencial: La primera lección siempre está abierta, 
        // las demás requieren que la anterior esté completada.
        bool isUnlocked = true;
        if (index > 0) {
          final previousLessonId = module.lessons[index - 1].id;
          isUnlocked = _completedLessons.contains(previousLessonId);
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isCompleted 
                  ? const Color(0xFF4A7C59) 
                  : (isUnlocked ? Colors.black12 : Colors.grey.withValues(alpha: 0.2)), 
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: ListTile(
            enabled: isUnlocked,
            leading: CircleAvatar(
              backgroundColor: isCompleted 
                  ? const Color(0xFF4A7C59) 
                  : (isUnlocked ? const Color(0xFF4A7C59).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
              child: Icon(
                isCompleted 
                    ? Icons.check_rounded 
                    : (isUnlocked ? Icons.menu_book_rounded : Icons.lock_outline_rounded), 
                color: isCompleted 
                    ? Colors.white 
                    : (isUnlocked ? const Color(0xFF4A7C59) : Colors.grey),
              ),
            ),
            title: Text(
              lesson.title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isUnlocked ? const Color(0xFF2D3A3A) : Colors.grey,
              ),
            ),
            subtitle: Text(
              isUnlocked ? "Objetivo: ${lesson.asanaTarget}" : "Completa la lección anterior para desbloquear",
              style: TextStyle(color: isUnlocked ? const Color(0xFF7A8D8D) : Colors.grey),
            ),
            trailing: Icon(
              isUnlocked ? Icons.arrow_forward_ios_rounded : Icons.lock, 
              size: 16, 
              color: isUnlocked ? const Color(0xFF7A8D8D) : Colors.grey,
            ),
            onTap: isUnlocked ? () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonDetailScreen(lesson: lesson)),
              );
              
              if (result == true) {
                _loadProgress();
              }
            } : null, // Si está bloqueado, no hace nada al pulsar
          ),
        );
      }),
      const SizedBox(height: 24),
    ],
  );
}
}