// Archivo: create_sequence_screen.dart

import 'package:flutter/material.dart';
import 'asana_model.dart';
import 'sequence.dart';
import 'custom_sequence_service.dart';

class CreateSequenceScreen extends StatefulWidget {
  const CreateSequenceScreen({super.key});

  @override
  State<CreateSequenceScreen> createState() => _CreateSequenceScreenState();
}

class _CreateSequenceScreenState extends State<CreateSequenceScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<String> _selectedAsanas = [];

  void _toggleAsana(String title) {
    setState(() {
      if (_selectedAsanas.contains(title)) {
        _selectedAsanas.remove(title);
      } else {
        _selectedAsanas.add(title);
      }
    });
  }

  Future<void> _saveSequence() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, asigna un nombre a la secuencia.")),
      );
      return;
    }

    if (_selectedAsanas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona al menos una postura.")),
      );
      return;
    }

    final newSequence = Sequence(
      id: "custom_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      description: desc.isEmpty ? "Secuencia personalizada" : desc,
      totalDurationMinutes: _selectedAsanas.length * 2, // Estimación básica de tiempo
      asanaList: _selectedAsanas,
    );

    await CustomSequenceService.saveCustomSequence(newSequence);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text(
          "Crear Secuencia",
          style: TextStyle(color: Color(0xFF2D3A3A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nombre de la rutina",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Ej. Mi Rutina Mañanera",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Descripción (Opcional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: "Ej. Enfoque en flexibilidad de espalda",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Selecciona las posturas (${_selectedAsanas.length} elegidas)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)),
            ),
            const SizedBox(height: 12),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AsanaModel.allAsanas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final asana = AsanaModel.allAsanas[index];
                final isSelected = _selectedAsanas.contains(asana.title);

                return InkWell(
                  onTap: () => _toggleAsana(asana.title),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4A7C59).withValues(alpha: 0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4A7C59) : Colors.black12,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(asana.icon, color: const Color(0xFF4A7C59)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            asana.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)),
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: isSelected ? const Color(0xFF4A7C59) : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _saveSequence,
                child: const Text(
                  "Guardar Rutina",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}