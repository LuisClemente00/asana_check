// Archivo: sequence_selection_screen.dart

import 'package:flutter/material.dart';
import 'sequence.dart';
import 'sequence_runner_screen.dart';
import 'custom_sequence_service.dart';
import 'create_sequence_screen.dart';

class SequenceSelectionScreen extends StatefulWidget {
  const SequenceSelectionScreen({super.key});

  @override
  State<SequenceSelectionScreen> createState() => _SequenceSelectionScreenState();
}

class _SequenceSelectionScreenState extends State<SequenceSelectionScreen> {
  List<Sequence> _customSequences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomSequences();
  }

  Future<void> _loadCustomSequences() async {
    final list = await CustomSequenceService.getCustomSequences();
    if (mounted) {
      setState(() {
        _customSequences = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSequences = [..._customSequences, ...sampleSequences];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          "Secuencias de Yoga",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4A7C59),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Crear Rutina", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSequenceScreen()),
          );
          if (created == true) {
            _loadCustomSequences();
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allSequences.length,
              itemBuilder: (context, index) {
                final sequence = allSequences[index];
                final isCustom = sequence.id.startsWith("custom_");

                return Card(
                  color: const Color(0xFF2D3A3A),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                sequence.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCustom)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () async {
                                  await CustomSequenceService.deleteCustomSequence(sequence.id);
                                  _loadCustomSequences();
                                },
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCustom ? const Color(0xFF4A7C59) : const Color(0xFF2D5AC8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${sequence.totalDurationMinutes} min",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sequence.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: sequence.asanaList.map((asana) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                asana,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A7C59),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SequenceRunnerScreen(sequence: sequence),
                                ),
                              );
                            },
                            child: const Text(
                              "Iniciar Secuencia",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}