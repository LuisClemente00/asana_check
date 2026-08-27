// Archivo: sequence_runner_screen.dart

import 'package:flutter/material.dart';
import 'sequence.dart'; 
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
      // Pasa a la siguiente postura de forma automática e inmediata
      setState(() {
        _currentIndex++;
      });
    } else {
      // Al terminar toda la secuencia, mostramos el resumen final
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