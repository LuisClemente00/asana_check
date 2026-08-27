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
  // ==========================================
  // SECUENCIAS INICIALES / BÁSICAS
  // ==========================================
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
    asanaList: ["La Cobra", "El Puente", "Perro Boca Abajo", "La Mariposa"],
  ),

  // ==========================================
  // NUEVAS SECUENCIAS TEMÁTICAS SPAINTOBALI
  // ==========================================
  const Sequence(
    id: "seq_4",
    title: "Despertar Solar en Bali",
    description: "Rutina matutina para activar articulaciones y despertar la energía del día.",
    totalDurationMinutes: 15,
    asanaList: [
      "El Árbol",
      "Perro Boca Abajo",
      "La Plancha",
      "La Cobra",
      "El Guerrero I",
      "El Triángulo"
    ],
  ),
  const Sequence(
    id: "seq_5",
    title: "Fuego & Poder del Guerrero",
    description: "Enfoque en resistencia muscular, fuerza en piernas y estabilización del core.",
    totalDurationMinutes: 25,
    asanaList: [
      "La Silla",
      "El Guerrero I",
      "El Guerrero II",
      "El Guerrero III",
      "El Barco",
      "El Puente"
    ],
  ),
  const Sequence(
    id: "seq_6",
    title: "Apertura Pélvica y Liberación",
    description: "Desbloquea caderas e ingles liberando el estrés acumulado.",
    totalDurationMinutes: 20,
    asanaList: [
      "La Pinza de Pie",
      "El Árbol",
      "La Paloma",
      "La Mariposa",
      "Señor de los Peces"
    ],
  ),
  const Sequence(
    id: "seq_7",
    title: "Fluidez y Centro (Vinyasa Flow)",
    description: "Coordinación, foco mental y equilibrio tridimensional continuo.",
    totalDurationMinutes: 30,
    asanaList: [
      "La Silla",
      "El Guerrero II",
      "El Triángulo",
      "La Media Luna",
      "El Camello",
      "La Pinza de Pie"
    ],
  ),
  const Sequence(
    id: "seq_8",
    title: "Atardecer Restaurativo Bali",
    description: "Secuencia nocturna para desacelerar el ritmo cardíaco y relajar la columna.",
    totalDurationMinutes: 15,
    asanaList: [
      "La Cobra",
      "La Paloma",
      "La Mariposa",
      "El Puente"
    ],
  ),
  const Sequence(
    id: "seq_9",
    title: "Inmersión Total",
    description: "Flujo completo de práctica integral recorriendo todas las familias de asanas.",
    totalDurationMinutes: 45,
    asanaList: [
      "Perro Boca Abajo",
      "La Plancha",
      "La Cobra",
      "La Silla",
      "El Guerrero I",
      "El Guerrero II",
      "El Guerrero III",
      "El Triángulo",
      "La Media Luna",
      "La Paloma",
      "El Camello",
      "El Barco",
      "Señor de los Peces",
      "El Puente",
      "La Mariposa"
    ],
  ),
];