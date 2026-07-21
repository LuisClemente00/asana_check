// Archivo: custom_sequence_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sequence.dart';

class CustomSequenceService {
  static const String _key = 'custom_sequences';

  static Future<List<Sequence>> getCustomSequences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_key);
    if (rawData == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(rawData);
      return jsonList.map((item) {
        return Sequence(
          id: item['id'] ?? '',
          title: item['title'] ?? '',
          description: item['description'] ?? '',
          totalDurationMinutes: (item['totalDurationMinutes'] as num? ?? 0).toInt(),
          asanaList: List<String>.from(item['asanaList'] ?? []),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCustomSequence(Sequence sequence) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCustomSequences();
    
    final index = current.indexWhere((s) => s.id == sequence.id);
    if (index >= 0) {
      current[index] = sequence;
    } else {
      current.add(sequence);
    }

    final String encoded = jsonEncode(current.map((s) => {
      'id': s.id,
      'title': s.title,
      'description': s.description,
      'totalDurationMinutes': s.totalDurationMinutes,
      'asanaList': s.asanaList,
    }).toList());

    await prefs.setString(_key, encoded);
  }

  static Future<void> deleteCustomSequence(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCustomSequences();
    current.removeWhere((s) => s.id == id);

    final String encoded = jsonEncode(current.map((s) => {
      'id': s.id,
      'title': s.title,
      'description': s.description,
      'totalDurationMinutes': s.totalDurationMinutes,
      'asanaList': s.asanaList,
    }).toList());

    await prefs.setString(_key, encoded);
  }
}