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

  // Lista ordenada de asanas seleccionadas para la secuencia
  final List<AsanaModel> _orderedSelectedAsanas = [];

  // Categoría/filtro activo de asanas
  String _searchQuery = "";

  void _toggleAsana(AsanaModel asana) {
    setState(() {
      if (_orderedSelectedAsanas.any((item) => item.title == asana.title)) {
        _orderedSelectedAsanas.removeWhere((item) => item.title == asana.title);
      } else {
        _orderedSelectedAsanas.add(asana);
      }
    });
  }

  void _reorderAsana(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _orderedSelectedAsanas.removeAt(oldIndex);
      _orderedSelectedAsanas.insert(newIndex, item);
    });
  }

  int _calculateTotalDurationMinutes() {
    if (_orderedSelectedAsanas.isEmpty) return 0;
    // Asumimos un promedio de 2 a 3 minutos por postura incluyendo descansos
    final totalSeconds = _orderedSelectedAsanas.length * 120;
    return (totalSeconds / 60).ceil();
  }

  Future<void> _saveSequence() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      // Línea ~58
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, asigna un nombre a la secuencia."),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    if (_orderedSelectedAsanas.isEmpty) {
      // Línea ~68
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona al menos una postura para tu secuencia."),
          backgroundColor: Colors.deepOrange,
        ),
      );
      return;
    }

    final newSequence = Sequence(
      id: "custom_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      description: desc.isEmpty ? "Secuencia personalizada SpainToBali" : desc,
      totalDurationMinutes: _calculateTotalDurationMinutes(),
      asanaList: _orderedSelectedAsanas.map((a) => a.title).toList(),
    );

    await CustomSequenceService.saveCustomSequence(newSequence);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsanas = AsanaModel.allAsanas.where((asana) {
      return asana.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text(
          "Crear Secuencia",
          style: TextStyle(
            color: Color(0xFF2D3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Nombre y Descripción de la Rutina
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nombre de la rutina",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Ej. Vinyasa Energizante de Bali",
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFFFFFDF).withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Descripción (Opcional)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          "Ej. Enfoque en apertura de caderas y fuerza de core.",
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFFFFFDF).withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Resumen de la Secuencia Actual (Con Reordenamiento Drag & Drop)
            if (_orderedSelectedAsanas.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Orden de la Secuencia (${_orderedSelectedAsanas.length})",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3A3A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "~${_calculateTotalDurationMinutes()} min",
                      style: const TextStyle(
                        color: Color(0xFF4A7C59),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Mantén pulsado y arrastra para cambiar el orden de las posturas:",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderedSelectedAsanas.length,
                onReorder: _reorderAsana,
                itemBuilder: (context, index) {
                  final asana = _orderedSelectedAsanas[index];
                  return Container(
                    key: ValueKey("selected_${asana.title}"),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        asana.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white70,
                            ),
                            onPressed: () => _toggleAsana(asana),
                          ),
                          const Icon(
                            Icons.drag_handle_rounded,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // 3. Catálogo de Selección de Asanas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Catálogo de Posturas",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A3A),
                  ),
                ),
                Text(
                  "${filteredAsanas.length} disponibles",
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Búsqueda rápida de asanas
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Buscar asana por nombre...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A7C59)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAsanas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final asana = filteredAsanas[index];
                final isSelected = _orderedSelectedAsanas.any(
                  (item) => item.title == asana.title,
                );

                return InkWell(
                  onTap: () => _toggleAsana(asana),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A7C59).withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A7C59)
                            : Colors.black12,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4A7C59)
                                : const Color(0xFFFFFFDF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            asana.icon,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF4A7C59),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asana.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF4A7C59)
                                      : const Color(0xFF2D3A3A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.add_circle_outline_rounded,
                          color: isSelected
                              ? const Color(0xFF4A7C59)
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // 4. Botón de Guardado
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _saveSequence,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Guardar Rutina (${_orderedSelectedAsanas.length} asanas)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
