// Archivo: sequence_runner_screen.dart

import 'package:flutter/material.dart';
import 'sequence.dart'; // <--- Cambiado de 'models/sequence.dart' a 'sequence.dart'
import 'pose_detector_screen.dart';
import 'pose_result_screen.dart';

class SequenceRunnerScreen extends StatefulWidget {
  final SequenceModel sequence;

  const SequenceRunnerScreen({super.key, required this.sequence});

  @override
  State<SequenceRunnerScreen> createState() => _SequenceRunnerScreenState();
}

class _SequenceRunnerScreenState extends State<SequenceRunnerScreen> {
  int _currentIndex = 0;
  int _totalTimeAccumulated = 0;

  void _onAsanaCompleted(int secondsSpent) {
    _totalTimeAccumulated += secondsSpent;

    if (_currentIndex < widget.sequence.asanaList.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _showTransitionDialog();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PoseResultScreen(
            asanaName: widget.sequence.title,
            secondsTrained: _totalTimeAccumulated,
          ),
        ),
      );
    }
  }

  void _showTransitionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D3A3A),
          title: const Text("¡Excelente trabajo!", style: TextStyle(color: Colors.white)),
          content: Text(
            "Siguiente postura: ${widget.sequence.asanaList[_currentIndex]}",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5AC8)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Continuar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAsana = widget.sequence.asanaList[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: PoseDetectorScreen(
              asanaName: currentAsana,
              onPoseCompleted: _onAsanaCompleted,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Postura ${_currentIndex + 1} de ${widget.sequence.asanaList.length}: $currentAsana",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}