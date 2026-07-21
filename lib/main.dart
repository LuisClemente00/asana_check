// Archivo: main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lobby_zen_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';
import 'notification_service.dart';
import 'calibration_screen.dart'; // Import necesario para la calibración

void main() async {
  // Aseguramos que los widgets estén inicializados antes de configurar servicios
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos las notificaciones
  await NotificationService.init();
  
  // Leemos la preferencia guardada de la hora, o usamos 18:00 por defecto
  final prefs = await SharedPreferences.getInstance();
  final hour = prefs.getInt('reminder_hour') ?? 18;
  final minute = prefs.getInt('reminder_minute') ?? 0;
  
  // Programamos el recordatorio con la hora configurada
  await NotificationService.scheduleDailyMindfulReminder(hour, minute); 
  
  runApp(const AsanaCheckApp());
}

class AsanaCheckApp extends StatelessWidget {
  const AsanaCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsanaCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFDF),
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final isFirstTime = snapshot.data!.getBool('isFirstTime') ?? true;
          return isFirstTime ? const OnboardingScreen() : const MainNavigationScreen();
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final Set<String> _completedAsanas = {};

  // --- Método de navegación hacia la calibración ---
  Future<void> _navigateToCalibration(String asanaName, int targetSeconds) async {
  final completed = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => CalibrationScreen(
        asanaName: asanaName,
        // Si tu CalibrationScreen acepta tiempo, se lo pasas aquí:
        // targetSeconds: targetSeconds, 
      ),
    ),
  );

  if (completed == true) {
    setState(() {
      _completedAsanas.add(asanaName);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      LobbyZenScreen(
        completedAsanas: _completedAsanas,
        onAsanaRequested: _navigateToCalibration, // Pasamos el manejador de navegación
      ),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFDF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "AsanaCheck".toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7C59),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      drawer: _buildZenDrawer(context),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF2D5AC8),
          unselectedItemColor: const Color(0xFF7A8D8D),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_outlined),
              activeIcon: Icon(Icons.spa_rounded),
              label: 'Práctica',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Progreso',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZenDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFFFFFDF),
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4A7C59)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.self_improvement_rounded, size: 45, color: Colors.white),
              ),
              accountName: Text("AsanaCheck", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("Tu IA de Yoga", style: TextStyle(color: Colors.white70)),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded, color: Color(0xFF4A7C59)),
              title: const Text('Nuestra Filosofía', style: TextStyle(color: Color(0xFF2D3A3A), fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _showPhilosophyDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline_rounded, color: Color(0xFF2D5AC8)),
              title: const Text('Soporte', style: TextStyle(color: Color(0xFF2D3A3A), fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Soporte AsanaCheck: info@asanacheck.com')),
                );
              },
            ),
            const Divider(color: Colors.black12, height: 20),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: Colors.redAccent),
              title: const Text('Reiniciar Progreso', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _completedAsanas.clear());
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "© 2026 AsanaCheck. Todos los derechos reservados.",
                style: TextStyle(fontSize: 10, color: Color(0xFF7A8D8D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhilosophyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFDF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.spa, color: Color(0xFF4A7C59)),
            SizedBox(width: 10),
            Text("Filosofía AsanaCheck"),
          ],
        ),
        content: const Text(
          "AsanaCheck democratiza el yoga mediante inteligencia artificial, permitiéndote practicar de forma autónoma, segura y alineada con tu propio entorno.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Namasté", style: TextStyle(color: Color(0xFF4A7C59), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}