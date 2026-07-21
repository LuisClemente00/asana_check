import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Lista de mensajes motivadores
  static final List<String> _mensajes = [
    'Tu espacio en AsanaCheck te espera. ¿Practicamos hoy?',
    'Unos minutos de yoga transforman tu día. ¡Vamos!',
    '¿Cómo te sientes hoy? Regálate un momento de calma.',
    'Tu cuerpo y tu mente te lo agradecerán. ¡Inicia una sesión!',
    'La constancia es la clave del bienestar. ¡Namasté!'
  ];

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> scheduleDailyMindfulReminder(int hour, int minute) async {
    // Seleccionamos un mensaje aleatorio
    final String randomMessage = _mensajes[Random().nextInt(_mensajes.length)];

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mindful_channel',
        'Recordatorios Mindful',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      'Momento de calma',
      randomMessage, // Usamos el mensaje aleatorio aquí
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}