// Archivo: calendar_screen.dart

import 'package:flutter/material.dart';
import 'history_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  Set<String> _practicedDays = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPracticedDays();
  }

  Future<void> _loadPracticedDays() async {
    final days = await HistoryService.getPracticedDays();
    if (mounted) {
      setState(() {
        _practicedDays = days;
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + increment, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDF),
      appBar: AppBar(
        title: const Text(
          "Calendario Zen",
          style: TextStyle(color: Color(0xFF2D3A3A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3A3A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Encabezado de Navegación de Mes ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D3A3A)),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          _formatMonthYear(_focusedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3A3A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF2D3A3A)),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Cuadrícula del Calendario ---
                  Container(
                    padding: const EdgeInsets.all(16),
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
                        _buildDaysOfWeekHeader(),
                        const SizedBox(height: 12),
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Leyenda de Indicadores ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A7C59),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Día de práctica",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3A3A),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Sin práctica",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A8D8D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    final List<String> days = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A8D8D),
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final int daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final int firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1 = Lunes

    final List<Widget> dayWidgets = [];

    // Espacios en blanco al inicio del mes
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final String dateKey = "${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
      final bool isPracticed = _practicedDays.contains(dateKey);
      final bool isToday = DateTime.now().year == _focusedMonth.year &&
          DateTime.now().month == _focusedMonth.month &&
          DateTime.now().day == day;

      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isPracticed ? const Color(0xFF4A7C59) : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: const Color(0xFF2D5AC8), width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              "$day",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPracticed
                    ? Colors.white
                    : (isToday ? const Color(0xFF2D5AC8) : const Color(0xFF2D3A3A)),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  String _formatMonthYear(DateTime date) {
    final List<String> months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return "${months[date.month - 1]} ${date.year}";
  }
}