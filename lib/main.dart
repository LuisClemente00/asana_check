import 'package:flutter/material.dart';
import 'lobby_zen_screen.dart';
import 'calibration_screen.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), // Crema arena suave
        fontFamily: 'Helvetica', // Tipografía limpia
        useMaterial3: true,
      ),
      home: const LobbyZenScreen(),
    );
  }
}