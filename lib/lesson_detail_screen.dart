// Archivo: lesson_detail_screen.dart

import 'package:flutter/material.dart';
import 'learning_path_model.dart';
import 'academy_progress_service.dart';
import 'gamification_service.dart';
import 'pose_detector_screen.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: const TextStyle(color: Color(0xFF2D3A3A)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description,
              style: const TextStyle(fontSize: 16, color: Color(0xFF2D3A3A)),
            ),
            const SizedBox(height: 24),

            // Puntos Clave
            _buildSectionTitle("Puntos Clave"),
            ...lesson.keyPoints.map(
              (point) => _buildBullet(
                point,
                Icons.check_circle,
                const Color(0xFF4A7C59),
              ),
            ),

            const SizedBox(height: 20),

            // Errores Comunes
            _buildSectionTitle("Errores Comunes"),
            ...lesson.commonErrors.map(
              (error) =>
                  _buildBullet(error, Icons.warning_rounded, Colors.redAccent),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PoseDetectorScreen(asanaName: lesson.asanaTarget),
                    ),
                  );

                  // Si la postura se completó con éxito
                  if (success == true) {
                    await AcademyProgressService.completeLesson(lesson.id);
                    
                    // Sumamos los XP de recompensa
                    await GamificationService.addXP(50);

                    // Regresamos a la pantalla anterior (AcademyScreen) indicando que hubo cambios
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
                child: const Text(
                  "Iniciar Práctica",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2D3A3A),
    ),
  );

  Widget _buildBullet(String text, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(0xFF2D3A3A))),
        ),
      ],
    ),
  );
}