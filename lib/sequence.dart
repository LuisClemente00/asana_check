// Archivo: sequence.dart

class Sequence {
  final String id;
  final String title;
  final String description;
  final int totalDurationMinutes;
  final List<String> asanaList;

  const Sequence({
    required this.id,
    required this.title,
    required this.description,
    required this.totalDurationMinutes,
    required this.asanaList,
  });
}

// Alias para evitar errores si en otros archivos usaste 'SequenceModel'
typedef SequenceModel = Sequence;

final List<Sequence> sampleSequences = [
  const Sequence(
    id: "seq_1",
    title: "Saludo al Sol A",
    description: "Secuencia fluida para calentar todo el cuerpo y activar la energía.",
    totalDurationMinutes: 10,
    asanaList: ["Perro Boca Abajo", "La Plancha", "La Cobra", "Perro Boca Abajo"],
  ),
  const Sequence(
    id: "seq_2",
    title: "Fuerza y Equilibrio",
    description: "Potencia el tren inferior y el centro con posturas de pie.",
    totalDurationMinutes: 15,
    asanaList: ["El Guerrero II", "El Guerrero I", "El Triángulo", "El Árbol", "La Silla"],
  ),
  const Sequence(
    id: "seq_3",
    title: "Relajación y Apertura",
    description: "Secuencia suave para estirar la espalda y liberar tensiones.",
    totalDurationMinutes: 12,
    asanaList: ["Gato-Vaca", "El Puente", "La Cobra", "Perro Boca Abajo"],
  ),
];