// Archivo: profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_storage.dart';
import 'notification_service.dart';
import 'gamification_service.dart';
import 'achievements_screen.dart';
import 'calendar_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _totalSessions = 0;
  int _totalMinutes = 0;
  String _favoriteAsana = "Ninguna";
  String _userName = "Yogui";
  int _xp = 0;
  String _levelName = "Yogui Novato 🌱";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final int currentHour = prefs.getInt('reminder_hour') ?? 18;
    final int currentMinute = prefs.getInt('reminder_minute') ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A7C59)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);
      await NotificationService.scheduleDailyMindfulReminder(
        picked.hour,
        picked.minute,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recordatorio ajustado a las ${picked.format(context)}',
          ),
          backgroundColor: const Color(0xFF4A7C59),
        ),
      );
    }
  }

  Future<void> _saveUsername(String newName) async {
    if (newName.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName.trim());
    setState(() {
      _userName = newName.trim();
    });
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFDF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Editar Nombre",
            style: TextStyle(
              color: Color(0xFF2D3A3A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Escribe tu nombre",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A7C59)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4A7C59),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Color(0xFF7A8D8D)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _saveUsername(controller.text);
                Navigator.pop(context);
              },
              child: const Text(
                "Guardar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final history = await SessionStorage.getSessionHistory();
    final xp = await GamificationService.getXP();

    int totalSeconds = 0;
    final Map<String, int> asanaCounts = {};

    for (var session in history) {
      totalSeconds += (session['seconds'] as num? ?? 0).toInt();
      final String asana = session['asana'] ?? 'Desconocida';
      asanaCounts[asana] = (asanaCounts[asana] ?? 0) + 1;
    }

    String fav = "Ninguna";
    int maxCount = 0;
    asanaCounts.forEach((asana, count) {
      if (count > maxCount) {
        maxCount = count;
        fav = asana;
      }
    });

    if (!mounted) return;

    setState(() {
      _userName = prefs.getString('username') ?? "Yogui";
      _totalSessions = history.length;
      _totalMinutes = totalSeconds ~/ 60;
      _favoriteAsana = fav;
      _xp = xp;
      _levelName = GamificationService.getLevelName(xp);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A7C59)),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4A7C59),
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  radius: 55,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.self_improvement_rounded,
                                    size: 65,
                                    color: Color(0xFF4A7C59),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showEditNameDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4A7C59),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3A3A),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF7A8D8D),
                                  size: 20,
                                ),
                                onPressed: _showEditNameDialog,
                              ),
                            ],
                          ),
                          Text(
                            _levelName,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4A7C59),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Panel de Estadísticas
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFF4A7C59),
                            label: "Sesiones Realizadas",
                            value: "$_totalSessions",
                          ),
                          const Divider(height: 24, color: Colors.black12),
                          _buildStatRow(
                            icon: Icons.timer_outlined,
                            iconColor: const Color(0xFF2D5AC8),
                            label: "Tiempo de Meditación",
                            value: "$_totalMinutes min",
                          ),
                          const Divider(height: 24, color: Colors.black12),
                          _buildStatRow(
                            icon: Icons.spa_rounded,
                            iconColor: Colors.orangeAccent,
                            label: "Asana Favorita",
                            value: _favoriteAsana,
                          ),
                          const Divider(height: 24, color: Colors.black12),
                          _buildStatRow(
                            icon: Icons.bolt_rounded,
                            iconColor: Colors.amber,
                            label: "Puntos de Experiencia",
                            value: "$_xp XP",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Acciones y Gamificación
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Mi Progreso Zen",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3A3A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.military_tech_rounded,
                          color: Color(0xFF4A7C59),
                        ),
                        title: const Text(
                          "Logros y Medallas",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text("Consulta tu rango e insignias"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AchievementsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Acceso al Calendario Zen ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF4A7C59),
                        ),
                        title: const Text(
                          "Calendario de Práctica",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Revisa los días que has entrenado",
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalendarScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Configuración
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Configuración",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3A3A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFF4A7C59),
                        ),
                        title: const Text(
                          "Nombre de usuario",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_userName),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: _showEditNameDialog,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.alarm_add_rounded,
                          color: Color(0xFF4A7C59),
                        ),
                        title: const Text(
                          "Hora del recordatorio",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          "Elige tu momento de calma diaria",
                        ),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: () => _pickReminderTime(context),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjeta Informativa
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A7C59).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF4A7C59).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF4A7C59),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Tu rincón de paz",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2D3A3A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Cada segundo que dedicas a tu cuerpo reduce el estrés acumulado. Sigue practicando.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(
                                      0xFF2D3A3A,
                                    ).withValues(alpha: 0.7),
                                    height: 1.3,
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
              ),
            ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3A3A),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3A3A),
          ),
        ),
      ],
    );
  }
}
