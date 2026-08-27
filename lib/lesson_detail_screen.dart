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
          style: const TextStyle(
            color: Color(0xFF2D3A3A),
            fontWeight: FontWeight.bold,
          ),
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
            // --- Encabezado y Categoría ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    lesson.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF4A7C59),
                ),
                Text(
                  lesson.readTime,
                  style: const TextStyle(
                    color: Color(0xFF7A8D8D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              lesson.overview,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF2D3A3A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // --- Sección 1: Filosofía y Origen ---
            _buildCardSection(
              title: "Filosofía y Origen (Parampara)",
              icon: Icons.auto_awesome,
              iconColor: Colors.amber.shade800,
              content: lesson.philosophyAndOrigin,
            ),
            const SizedBox(height: 16),

            // --- Sección 2: Biomecánica y Anatomía ---
            _buildCardSection(
              title: "Anatomía y Biomecánica",
              icon: Icons.accessibility_new_rounded,
              iconColor: Colors.indigo,
              content: lesson.biomechanicsAndAlignment,
            ),
            const SizedBox(height: 16),

            // --- Sección 3: Pranayama (Respiración) y Drishti (Enfoque) ---
            Row(
              children: [
                Expanded(
                  child: _buildMiniCard(
                    title: "Pranayama",
                    content: lesson.pranayamaAndEnergy,
                    icon: Icons.air_rounded,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniCard(
                    title: "Drishti (Mirada)",
                    content: lesson.drishtiAndFocus,
                    icon: Icons.remove_red_eye_rounded,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Sección 4: Puntos Clave de Alineación ---
            _buildSectionTitle("Pautas de Alineación"),
            ...lesson.keyPoints.map(
              (point) => _buildBullet(
                point,
                Icons.check_circle_outline_rounded,
                const Color(0xFF4A7C59),
              ),
            ),
            const SizedBox(height: 20),

            // --- Sección 5: Errores Comunes ---
            _buildSectionTitle("Errores Comunes a Evitar"),
            ...lesson.commonErrors.map(
              (error) => _buildBullet(
                error,
                Icons.warning_amber_rounded,
                Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),

            // --- Sección 6: Variaciones y Adaptaciones ---
            _buildSectionTitle("Variaciones y Adaptaciones"),
            ...lesson.variations.map(
              (v) => _buildBullet(
                v,
                Icons.alt_route_rounded,
                Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 36),

            // --- Botón de Acción Principal ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                label: const Text(
                  "Iniciar Práctica en Cámara",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final success = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseDetectorScreen(
                        asanaName: lesson.asanaTarget,
                      ),
                    ),
                  );

                  if (success == true) {
                    await AcademyProgressService.completeLesson(lesson.id);
                    await GamificationService.addXP(50);

                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3A3A),
          ),
        ),
      );

  Widget _buildBullet(String text, IconData icon, Color color) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF2D3A3A),
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF4A5555),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Color(0xFF2D3A3A),
            ),
          ),
        ],
      ),
    );
  }
}