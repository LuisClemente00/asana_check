// Archivo: learning_path_model.dart

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String asanaTarget;
  final String pranayama;
  final String drishti;
  final List<String> keyPoints;
  final List<String> commonErrors;
  final List<String> yogicTips;

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.asanaTarget,
    required this.pranayama,
    required this.drishti,
    required this.keyPoints,
    required this.commonErrors,
    required this.yogicTips,
  });
}

class Module {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.lessons,
  });
}

final List<Module> sampleModules = [
  Module(
    id: 'm1',
    title: 'Módulo 1: Fundamentos y Enraizamiento',
    description: 'Bases biomecánicas, postura erguida y conexión con la tierra.',
    iconName: 'spa',
    lessons: [
      Lesson(
        id: 'l1',
        title: 'La Montaña sagrada',
        subtitle: 'Tadasana',
        description: 'La postura reina de la alineación. Enseña a distribuir el peso de forma equitativa y mantener la columna neutra.',
        asanaTarget: 'El Árbol',
        pranayama: 'Respiración Ujjayi (profunda y sonora por la nariz).',
        drishti: 'Hacia el horizonte, fijando la mirada sin tensión.',
        keyPoints: [
          'Activa Padabandha: apoya firmemente metatarsos y talón.',
          'Mete suavemente el sacro y activa el abdomen inferior.',
          'Rota externamente los hombros hacia atrás y abajo.',
          'Alarga la coronilla hacia el cielo.',
        ],
        commonErrors: [
          'Hiperlordosis: arquear la espalda baja en exceso.',
          'Colapsar los arcos de los pies hacia adentro.',
          'Tensar la mandíbula o elevar los hombros.',
        ],
        yogicTips: [
          'Tadasana busca encarnar la estabilidad inmóvil de una montaña.',
        ],
      ),
      Lesson(
        id: 'l2',
        title: 'El Árbol firme',
        subtitle: 'Vrksasana',
        description: 'Aprende a enraizar una pierna mientras abres la cadera y buscas equilibrio físico y emocional.',
        asanaTarget: 'El Árbol',
        pranayama: 'Respiración rítmica e inhalaciones largas.',
        drishti: 'Un punto fijo (Drishti) a 2 metros de distancia.',
        keyPoints: [
          'Enraíza el pie de apoyo abriendo los dedos al máximo.',
          'Coloca la planta en el muslo interno o pantorrilla (nunca en la rodilla).',
          'Presiona el pie contra el muslo y viceversa para crear estabilidad.',
          'Lleva las palmas juntas al centro del pecho.',
        ],
        commonErrors: [
          'Presionar directamente sobre la articulación de la rodilla.',
          'Dejar caer la cadera de la pierna de apoyo.',
        ],
        yogicTips: [
          'Busca raíces fuertes en la base y flexibilidad fluida en las ramas.',
        ],
      ),
    ],
  ),
  Module(
    id: 'm2',
    title: 'Módulo 2: Fuerza y Apertura',
    description: 'Fuerza en extremidades, apertura de caderas y resistencia.',
    iconName: 'fitness_center',
    lessons: [
      Lesson(
        id: 'l3',
        title: 'El Guerrero pacífico',
        subtitle: 'Virabhadrasana II',
        description: 'Cultiva la determinación interior y fortalece cuádriceps, glúteos y resistencia mental.',
        asanaTarget: 'El Guerrero II',
        pranayama: 'Inhalación expansiva y exhalación enraizante.',
        drishti: 'Por encima de la punta del dedo corazón de la mano delantera.',
        keyPoints: [
          'Flexiona la rodilla delantera a 90° sobre el tobillo.',
          'Presiona el borde externo del pie trasero.',
          'Abre los brazos en línea horizontal continua.',
        ],
        commonErrors: [
          'Colapso de la rodilla delantera hacia el interior.',
          'Elevar los hombros apretando el cuello.',
        ],
        yogicTips: [
          'El verdadero guerrero lucha contra la ignorancia y la agitación mental.',
        ],
      ),
    ],
  ),
  Module(
    id: 'm3',
    title: 'Módulo 3: Centro y Control',
    description: 'Tonificación de la faja abdominal y control del equilibrio.',
    iconName: 'bolt',
    lessons: [
      Lesson(
        id: 'l4',
        title: 'La Plancha consciente',
        subtitle: 'Phalakasana',
        description: 'Construye la fuerza estructural necesaria para la práctica.',
        asanaTarget: 'La Plancha',
        pranayama: 'Respiración intercostal constante sin sostener el aire.',
        drishti: 'Ligeramente al frente en el suelo.',
        keyPoints: [
          'Empuja la esterilla alejando las escápulas entre sí.',
          'Forma una diagonal perfecta de talones a coronilla.',
          'Activa abdomen y glúteos.',
        ],
        commonErrors: [
          'Dejar caer la cadera cargando la zona lumbar.',
          'Subir los glúteos formando una V.',
        ],
        yogicTips: [
          'El fuego interno purifica el cuerpo y fortalece la voluntad.',
        ],
      ),
    ],
  ),
];

// Alias para mantener compatibilidad si academy_screen usa academyModules
final List<Module> academyModules = sampleModules;