// Archivo: learning_path_model.dart

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final String overview;

  // Campo de compatibilidad
  String get description => overview;

  // Secciones didácticas profundas
  final String philosophyAndOrigin;
  final String biomechanicsAndAlignment;
  final String pranayamaAndEnergy;
  final String drishtiAndFocus;

  final List<String> keyPoints;
  final List<String> commonErrors;
  final List<String> safetyAndLimits;
  final List<String> variations;

  final String asanaTarget;

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.overview,
    required this.philosophyAndOrigin,
    required this.biomechanicsAndAlignment,
    required this.pranayamaAndEnergy,
    required this.drishtiAndFocus,
    required this.keyPoints,
    required this.commonErrors,
    required this.safetyAndLimits,
    required this.variations,
    required this.asanaTarget,
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
  // ==========================================
  // MÓDULO 1: FUNDAMENTOS Y ENRAIZAMIENTO
  // ==========================================
  Module(
    id: 'm1',
    title: 'Módulo 1: Fundamentos y Enraizamiento',
    description: 'Anatomía postural, biomecánica articular y alineación consciente de la columna vertebral.',
    iconName: 'spa',
    lessons: [
      Lesson(
        id: 'l1',
        title: 'Anatomía de la Postura Erguida',
        subtitle: 'Tadasana (La Montaña)',
        category: 'Fundamentos Posturales',
        readTime: '6 min de lectura',
        overview: 'Tadasana no es simplemente "estar de pie". Es la matriz biomecánica desde la cual nacen todas las demás posturas de yoga de pie.',
        philosophyAndOrigin:
            'En la tradición del Hatha Yoga, Tadasana simboliza la inmovilidad majestuosa del monte Meru, el centro axial del universo. Invita a cultivar "Sthira" (firmeza) y "Sukham" (comodidad).',
        biomechanicsAndAlignment:
            'Buscamos neutralizar las curvas de la columna vertebral. Los arcos del pie (Padabandha) se activan elevando la fascia plantar. Los cuádriceps se contraen para elevar las rótulas, estabilizando las rodillas.',
        pranayamaAndEnergy:
            'Practica la respiración Ujjayi. Ajusta el paso del aire en la glotis creando un suave sonido oceánico que incrementa la presión intraabdominal y estabiliza el core.',
        drishtiAndFocus:
            'Nasa-agra Drishti (fijación en la punta de la nariz) o mirada fija en el horizonte para pacificar el sistema nervioso.',
        keyPoints: [
          'Junta los metatarsos de los dedos gordos y separa ligeramente los talones (1-2 cm).',
          'Distribuye el peso equitativamente entre los cuatro puntos de cada pie.',
          'Mantén el mentón paralelo al suelo y la coronilla apuntando al techo.',
          'Aleja las clavículas del esternón abriendo la caja torácica.',
        ],
        commonErrors: [
          'Hiperlordosis lumbar: dejar caer la pelvis hacia adelante.',
          'Bloquear las articulaciones de las rodillas (hiperconexión posterior).',
          'Elevar los hombros hacia las orejas generando sobrecarga en el trapecio.',
        ],
        safetyAndLimits: [
          'Personas con mareos o vértigo deben practicar con los pies separados al ancho de caderas.',
          'En caso de presión arterial baja, evitar mantener la postura con ojos cerrados por periodos prolongados.',
        ],
        variations: [
          'Principiantes: Realizar apoyando la espalda suavemente contra una pared.',
          'Avanzado: Cerrar los ojos para eliminar la referencia visual y potenciar la propiocepción.',
        ],
        asanaTarget: 'El Árbol',
      ),
      Lesson(
        id: 'l2',
        title: 'Arquitectura del Equilibrio Unipodal',
        subtitle: 'Vrksasana (El Árbol)',
        category: 'Equilibrio y Propiocepción',
        readTime: '7 min de lectura',
        overview: 'Explora la transferencia de carga unilateral, la rotación externa de cadera y el control neuro-muscular profundo.',
        philosophyAndOrigin:
            'Vrksasana evoca la resiliencia de los árboles: raíces profundas y fijas en la tierra con ramas flexibles que ceden al viento.',
        biomechanicsAndAlignment:
            'El glúteo medio se activa fuertemente para evitar la caída de la pelvis. En la pierna flexionada, los rotadores externos abren el fémur lateralmente.',
        pranayamaAndEnergy:
            'Mantiene un ritmo respiratorio Samavritti (respiración cuadrada de 4 segundos) para equilibrar los hemisferios cerebrales.',
        drishtiAndFocus:
            'Drishti en un punto fijo estático a 2 metros en el suelo para enviar información al sistema vestibular.',
        keyPoints: [
          'Abre en abanico los dedos del pie base para ampliar la superficie de soporte.',
          'Coloca la planta del pie elevado por encima o por debajo de la rodilla, jamás sobre la articulación.',
          'Presiona activamente el pie contra el muslo interno y responde con la misma fuerza.',
          'Eleva los brazos sobre la cabeza manteniendo los hombros lejos de las cervicales.',
        ],
        commonErrors: [
          'Apoyar el talón sobre la articulación lateral de la rodilla.',
          'Girar toda la pelvis hacia el lado de la pierna abierta.',
          'Agarrar la esterilla con los dedos del pie contraídos.',
        ],
        safetyAndLimits: [
          'Evitar colocar el pie en la rodilla si hay antecedentes de lesión de ligamentos.',
          'Personas con inestabilidad de tobillo deben usar una pared como punto de apoyo.',
        ],
        variations: [
          'Principiante: Apoyar únicamente el talón elevado sobre el tobillo del pie base.',
          'Avanzado: Llevar la pierna flexionada a Medio Loto (Ardha Padmasana).',
        ],
        asanaTarget: 'El Árbol',
      ),
      Lesson(
        id: 'l3',
        title: 'Fuerza de Asiento y Fuego Interno',
        subtitle: 'Utkatasana (La Silla)',
        category: 'Fuerza e Intensidad',
        readTime: '6 min de lectura',
        overview: 'Despierta el calor interno, fortalece los muslos y glúteos y mejora la movilidad de los hombros.',
        philosophyAndOrigin:
            'Utkata significa "fiero" o "poderoso". Invita a sostener la incomodidad física mediante la ecuanimidad mental.',
        biomechanicsAndAlignment:
            'Flexión profunda de caderas y rodillas manteniendo el torso erguido. Fuerte activación de glúteos y cuádriceps.',
        pranayamaAndEnergy:
            'Respiración Ujjayi constante y rítmica para canalizar el fuego interno generado.',
        drishtiAndFocus:
            'Mirada hacia las manos elevadas o al espacio entre los pulgares.',
        keyPoints: [
          'Mantén las rodillas juntas asegurándote de poder ver las puntas de tus pies.',
          'Desplaza el peso corporal hacia los talones.',
          'Desciende la pelvis como si te sentaras en una silla invisible.',
        ],
        commonErrors: [
          'Dejar que las rodillas sobrepasen excesivamente la punta de los pies.',
          'Arquear la espalda baja en exceso.',
        ],
        safetyAndLimits: [
          'Personas con problemas cardíacos o presión alta deben mantener las manos en el pecho.',
        ],
        variations: [
          'Principiante: Practicar apoyando la espalda contra una pared.',
          'Avanzado: Elevar los talones del suelo manteniéndose sobre las puntas de los pies.',
        ],
        asanaTarget: 'La Silla',
      ),
      Lesson(
        id: 'l4',
        title: 'Extensión Pectoral y Columna Lumbar',
        subtitle: 'Bhujangasana (La Cobra)',
        category: 'Extensión de Columna',
        readTime: '6 min de lectura',
        overview: 'Fortalece la musculatura posterior de la columna, abre el pecho y estimula la digestión.',
        philosophyAndOrigin:
            'Representa a la serpiente que despierta y eleva la energía Kundalini desde la base de la columna.',
        biomechanicsAndAlignment:
            'Activación de los erectores espinales. Presión activa del pubis y empeines contra el suelo para estabilizar la pelvis.',
        pranayamaAndEnergy:
            'Inhalación profunda al elevar el pecho expandiendo Anahata Chakra. Exhalación lenta al descender.',
        drishtiAndFocus:
            'Bhrumadhya Drishti (fijación en el entrecejo) o mirada suave hacia el techo.',
        keyPoints: [
          'Coloca las manos justo debajo de las axilas con codos pegados al cuerpo.',
          'Usa la fuerza de la espalda para subir, no empujes únicamente con los brazos.',
          'Mantén los hombros rotados hacia atrás y abajo.',
        ],
        commonErrors: [
          'Empujar con fuerza despegando la pelvis del suelo e hiperextendiendo la zona lumbar.',
          'Separar los codos hacia los lados.',
        ],
        safetyAndLimits: [
          'En caso de hernia discal lumbar activa o embarazo, realizar la variante de la Esfinge.',
        ],
        variations: [
          'Principiante: La Esfinge (apoyando antebrazos en el suelo).',
          'Avanzado: Cobra completa extendiendo brazos y abriendo la garganta.',
        ],
        asanaTarget: 'La Cobra',
      ),
      Lesson(
        id: 'l5',
        title: 'Apertura Pasiva de Caderas',
        subtitle: 'Baddha Konasana (La Mariposa)',
        category: 'Flexibilidad Pélvica',
        readTime: '5 min de lectura',
        overview: 'Libera la rigidez acumulada en los aductores e ingles, promoviendo la relajación pélvica.',
        philosophyAndOrigin:
            'Simboliza el aleteo constante de una mariposa, enseñando a soltar las tensiones emocionales atrapadas en la cadera.',
        biomechanicsAndAlignment:
            'Rotación externa y abducción femorales. La columna permanece alargada desde los isquiones hasta la coronilla.',
        pranayamaAndEnergy:
            'Respiración abdominal suave y profunda, guiando la energía Apana hacia abajo para soltar tensiones.',
        drishtiAndFocus:
            'Nasa-agra Drishti (punta de la nariz) manteniendo el cuello alargado.',
        keyPoints: [
          'Junta las plantas de los pies y deja caer las rodillas hacia los lados.',
          'Sujeta los pies o tobillos manteniendo los hombros relajados.',
          'Eleva el esternón antes de inclinarse hacia adelante.',
        ],
        commonErrors: [
          'Encorvar excesivamente la espalda alta por intentar tocar los pies con la cabeza.',
          'Forzar las rodillas hacia el suelo con las manos.',
        ],
        safetyAndLimits: [
          'Si hay dolor en rodillas, colocar bloques o cojines debajo de los muslos como tope.',
        ],
        variations: [
          'Principiante: Sentarse sobre un cojín o bloque para elevar la pelvis.',
          'Avanzado: Plegar el torso completamente hacia adelante apoyando la frente en el suelo.',
        ],
        asanaTarget: 'La Mariposa',
      ),
    ],
  ),

  // ==========================================
  // MÓDULO 2: LA FUERZA DEL GUERRERO
  // ==========================================
  Module(
    id: 'm2',
    title: 'Módulo 2: La Fuerza del Guerrero',
    description: 'Desarrolla determinación, fuerza en miembros inferiores e inclinaciones pélvicas potentes.',
    iconName: 'fitness_center',
    lessons: [
      Lesson(
        id: 'l6',
        title: 'Encuadre Pélvico y Extensión Frontal',
        subtitle: 'Virabhadrasana I (Guerrero I)',
        category: 'Fuerza y Apertura',
        readTime: '7 min de lectura',
        overview: 'Combina un paso largo en flexión con el encuadre de las caderas al frente y elevación de brazos.',
        philosophyAndOrigin:
            'Representa la salida del guerrero Virabhadra desde la tierra, listo para la batalla con foco y determinación.',
        biomechanicsAndAlignment:
            'La pierna delantera se flexiona a 90° mientras la pierna trasera se estira con el talón apoyado a 45°. Fuerte trabajo de estabilización de cadera.',
        pranayamaAndEnergy:
            'Inhalaciones expansivas hacia el pecho mientras los brazos se proyectan al cielo.',
        drishtiAndFocus:
            'Angustha Ma Dyai Drishti: Fijación en los dedos pulgares sobre la cabeza.',
        keyPoints: [
          'Alinea la rodilla delantera sobre el tobillo.',
          'Gira la cadera trasera hacia el frente buscando encuadrar ambos ilíacos.',
          'Mantén el talón posterior apoyado con firmeza.',
        ],
        commonErrors: [
          'Despegar el borde externo del pie trasero.',
          'Arquear en exceso la espalda baja sin activar el abdomen.',
        ],
        safetyAndLimits: [
          'En caso de molestia lumbar, despegar el talón trasero realizando la variante de Zancada Alta (High Lunge).',
        ],
        variations: [
          'Principiante: Acortar la distancia entre los pies.',
          'Avanzado: Juntar las palmas en Anjali Mudra inclinando suavemente el torso atrás.',
        ],
        asanaTarget: 'El Guerrero I',
      ),
      Lesson(
        id: 'l7',
        title: 'Anatomía del Guerrero Heroico',
        subtitle: 'Virabhadrasana II (Guerrero II)',
        category: 'Fuerza y Apertura',
        readTime: '8 min de lectura',
        overview: 'Sostén la fuerza estructural en las piernas mientras expandes el pecho y las caderas en planos opuestos.',
        philosophyAndOrigin:
            'Encarna la ecuanimidad y el coraje espiritual para enfrentar el ego (Ahamkara) y las distracciones de la mente.',
        biomechanicsAndAlignment:
            'La pierna delantera está en flexión (90°), abducción y rotación externa. La trasera está en extensión y rotación interna.',
        pranayamaAndEnergy:
            'Inhalaciones dirigidas a las costillas laterales. Exhalaciones lentas visualizando el enraizamiento a tierra.',
        drishtiAndFocus:
            'Hastagrai Drishti: Enfoca la mirada en el dedo corazón de la mano delantera.',
        keyPoints: [
          'Alinea la rodilla delantera exactamente encima del tobillo a 90°.',
          'Traza una línea desde el talón delantero hasta el arco del pie trasero.',
          'Presiona firmemente el borde externo del pie posterior.',
          'Mantén el torso perfectamente vertical sobre la pelvis.',
        ],
        commonErrors: [
          'Dejar que la rodilla delantera colapse internamente (valgo).',
          'Inclinar el tronco hacia adelante persiguiendo la mano frontal.',
        ],
        safetyAndLimits: [
          'Si hay molestia en la rodilla delantera, reducir el ángulo de flexión a 60°.',
        ],
        variations: [
          'Principiante: Reducir la separación entre pies.',
          'Avanzado: Profundizar la flexión hasta dejar el muslo paralelo al suelo.',
        ],
        asanaTarget: 'El Guerrero II',
      ),
      Lesson(
        id: 'l8',
        title: 'Equilibrio Flotante en T',
        subtitle: 'Virabhadrasana III (Guerrero III)',
        category: 'Equilibrio Avanzado',
        readTime: '8 min de lectura',
        overview: 'Postura de equilibrio unipodal donde el torso y la pierna trasera flotan paralelos al suelo formando una T.',
        philosophyAndOrigin:
            'Representa al guerrero avanzando con precisión en el aire, exigiendo foco mental inquebrantable.',
        biomechanicsAndAlignment:
            'Intensa activación del glúteo mayor y los isquiotibiales de la pierna levantada. El core sostiene la columna neutra.',
        pranayamaAndEnergy:
            'Respiración fluida y contante. Inhalaciones que alargan el cuerpo de punta a punta.',
        drishtiAndFocus:
            'Mirada fija hacia un punto estático en el suelo a 1 metro por delante.',
        keyPoints: [
          'Mantén la cadera levantada nivelada con la cadera base.',
          'Proyecta el talón trasero hacia atrás en flexión dorsal (pie en flex).',
          'Alarga los brazos hacia adelante o al lado del cuerpo.',
        ],
        commonErrors: [
          'Rotar y elevar la cadera de la pierna flotante hacia arriba.',
          'Encorvar la espalda dejando caer los hombros.',
        ],
        safetyAndLimits: [
          'Utilizar bloques bajo las manos si hay falta de flexibilidad o equilibrio.',
        ],
        variations: [
          'Principiante: Apoyar las manos en el suelo o sobre bloques (Guerrero III asistido).',
          'Avanzado: Extender ambos brazos al frente alineados con las orejas.',
        ],
        asanaTarget: 'El Guerrero III',
      ),
      Lesson(
        id: 'l9',
        title: 'Inclinación e Inclinación Humilde',
        subtitle: 'Baddha Virabhadrasana (Guerrero Humilde)',
        category: 'Apertura de Hombros y Caderas',
        readTime: '7 min de lectura',
        overview: 'Combina la fuerza del Guerrero II con una inclinación del torso por dentro de la rodilla y entrelazado de manos.',
        philosophyAndOrigin:
            'Invita a doblegar el orgullo rindiendo la cabeza a la tierra en un gesto de devoción y humildad.',
        biomechanicsAndAlignment:
            'Flexión profunda de cadera con abducción del torso. Los deltoides y romboides tiran de las escápulas atrás.',
        pranayamaAndEnergy:
            'Exhalación profunda al bajar el torso, soltando el peso de la cabeza.',
        drishtiAndFocus:
            'Mirada dirigida hacia los dedos del pie trasero o el talón posterior.',
        keyPoints: [
          'Entrelaza las manos detrás de la espalda y extiende los codos.',
          'Desciende el hombro delantero por el lado interno de la rodilla.',
          'Suelta completamente la tensión del cuello.',
        ],
        commonErrors: [
          'Apoyar el peso del torso directamente sobre el muslo delantero.',
          'Perder la tensión en la pierna trasera.',
        ],
        safetyAndLimits: [
          'Si hay dolor de hombros, usar una correa entre las manos en lugar de entrelazar los dedos.',
        ],
        variations: [
          'Principiante: Apoyar las manos en el suelo a los lados del pie delantero.',
          'Avanzado: Elevar los puños entrelazados por encima de la cabeza hacia el suelo.',
        ],
        asanaTarget: 'Guerrero Humilde',
      ),
    ],
  ),

  // ==========================================
  // MÓDULO 3: APERTURA Y FLEXIBILIDAD
  // ==========================================
  Module(
    id: 'm3',
    title: 'Módulo 3: Apertura y Flexibilidad',
    description: 'Movilidad articular profunda, elongación de isquiotibiales y flexibilidad espinal.',
    iconName: 'self_improvement',
    lessons: [
      Lesson(
        id: 'l10',
        title: 'Geometría y Extensión Lateral',
        subtitle: 'Utthita Trikonasana (El Triángulo)',
        category: 'Flexibilidad e Isquiotibiales',
        readTime: '7 min de lectura',
        overview: 'Abre la caja torácica, estira los isquiotibiales y descomprime la columna en una extensión lateral limpia.',
        philosophyAndOrigin:
            'El triángulo simboliza las tres fuerzas primarias del universo (Gunas): Sattva, Rajas y Tamas.',
        biomechanicsAndAlignment:
            'La flexión nace desde la articulación coxofemoral. Mantiene la elongación de ambos costados del torso.',
        pranayamaAndEnergy:
            'Respiración intercostal expansiva llenando el pulmón superior.',
        drishtiAndFocus:
            'Angustha Ma Dyai Drishti: Mirada hacia el pulgar de la mano elevada.',
        keyPoints: [
          'Ambas piernas se mantienen extendidas sin bloquear las rodillas.',
          'Inclina el torso desde la cadera hacia la pierna delantera.',
          'Alinea el brazo superior verticalmente sobre el inferior.',
        ],
        commonErrors: [
          'Rotar los hombros y el pecho hacia el suelo por querer tocar el pie.',
          'Hiper-extender la rodilla delantera.',
        ],
        safetyAndLimits: [
          'Si hay molestia cervical, mirar hacia el suelo en lugar de la mano elevada.',
        ],
        variations: [
          'Principiante: Apoyar la mano inferior sobre un bloque junto a la espinilla.',
          'Avanzado: Elevar ambos brazos paralelos a las orejas sosteniendo con el core.',
        ],
        asanaTarget: 'El Triángulo',
      ),
      Lesson(
        id: 'l11',
        title: 'Plegado Profundo e Isquiotibiales',
        subtitle: 'Uttanasana (La Pinza de Pie)',
        category: 'Flexibilidad de Cadena Posterior',
        readTime: '6 min de lectura',
        overview: 'Flexión profunda del torso hacia las piernas para elongar isquiotibiales y calmar la mente.',
        philosophyAndOrigin:
            'Uttana significa "estiramiento intenso". Es una postura de introspección y entrega consciente.',
        biomechanicsAndAlignment:
            'Inclinación anterior pélvica. Alargamiento de gastrocnemios, isquiotibiales y erectores espinales.',
        pranayamaAndEnergy:
            'Exhalaciones prolongadas para vaciar el abdomen y profundizar el pliegue.',
        drishtiAndFocus:
            'Nasa-agra Drishti mirando la punta de la nariz o entre las rodillas.',
        keyPoints: [
          'Plega el torso desde las caderas, manteniendo la columna neutra el mayor tiempo posible.',
          'Lleva el peso ligeramente hacia los metatarsos del pie.',
          'Deja caer la cabeza relajando trapecios y cervicales.',
        ],
        commonErrors: [
          'Encorvar bruscamente la espalda alta en vez de flexionar desde la cadera.',
          'Bloquear las rodillas impulsando la articulación hacia atrás.',
        ],
        safetyAndLimits: [
          'En caso de hernia discal, flexionar las rodillas lo suficiente para mantener la columna recta.',
        ],
        variations: [
          'Principiante: Flexionar rodillas apoyando las manos en bloques.',
          'Avanzado: Colocar las palmas completamente bajo las plantas de los pies (Padahastasana).',
        ],
        asanaTarget: 'La Pinza de Pie',
      ),
      Lesson(
        id: 'l12',
        title: 'Apertura Profunda de Rotadores Pélvicos',
        subtitle: 'Eka Pada Rajakapotasana (La Paloma)',
        category: 'Apertura de Cadera',
        readTime: '8 min de lectura',
        overview: 'Postura intensa de apertura de cadera que libera los músculos piriforme, glúteos y psoas.',
        philosophyAndOrigin:
            'Simboliza la gracia y elegancia de la paloma real, purificando las tensiones acumuladas en la pelvis.',
        biomechanicsAndAlignment:
            'La pierna delantera se sitúa en flexión y rotación externa, mientras la trasera se extienda neutra en el suelo.',
        pranayamaAndEnergy:
            'Respiraciones profundas y dirigidas a la zona pélvica para permitir la cesión muscular.',
        drishtiAndFocus:
            'Bhrumadhya Drishti (entrecejo) o mirada hacia el frente.',
        keyPoints: [
          'Mantén ambas caderas niveladas y paralelas al borde frontal de la esterilla.',
          'Extiende la pierna trasera recta hacia atrás con el empeine apoyado.',
          'Coloca un cojín o bloque bajo el glúteo delantero si la cadera flota.',
        ],
        commonErrors: [
          'Dejarse caer sobre el glúteo de la pierna flexionada desalineando la cadera.',
          'Forzar la rodilla delantera flexionada.',
        ],
        safetyAndLimits: [
          'Si hay dolor de rodilla, realizar la postura de la Paloma Supina (Figura 4 tumbado boca arriba).',
        ],
        variations: [
          'Principiante: Paloma tumbada boca arriba abrazando el muslo contrario.',
          'Avanzado: Flexionar la pierna trasera sujetando el pie con la mano (Paloma Real).',
        ],
        asanaTarget: 'La Paloma',
      ),
      Lesson(
        id: 'l13',
        title: 'Apertura Torácica y Extensión Posterior',
        subtitle: 'Ustrasana (El Camello)',
        category: 'Extensión Profunda',
        readTime: '7 min de lectura',
        overview: 'Arqueo de columna desde las rodillas que abre el pecho, hombros y cuádriceps.',
        philosophyAndOrigin:
            'Evoca la resistencia del camello en el desierto, enseñando a abrir el corazón con valentía.',
        biomechanicsAndAlignment:
            'Extensión de caderas mantenida por los glúteos y psoas. Los deltoides posteriores llevan las manos a los talones.',
        pranayamaAndEnergy:
            'Inhalación amplia llenando la parte superior del tórax expandiendo Vishuddha Chakra.',
        drishtiAndFocus:
            'Nasa-agra Drishti o mirada suave al techo sin colapsar el cuello atrás.',
        keyPoints: [
          'Colócate de rodillas separadas al ancho de las caderas.',
          'Empuja la pelvis hacia adelante manteniéndola sobre la vertical de las rodillas.',
          'Lleva las manos a las lumbares antes de buscar los talones.',
        ],
        commonErrors: [
          'Dejar caer la cadera hacia atrás perdiendo la alineación vertical sobre las rodillas.',
          'Colapsar la zona lumbar sin elevación torácica.',
        ],
        safetyAndLimits: [
          'Si hay molestias cervicales, mantener el mentón recogido hacia el pecho.',
        ],
        variations: [
          'Principiante: Apoyar los dedos de los pies en flexión para elevar los talones.',
          'Avanzado: Apoyar los empeines planos e inclinar la cabeza suavemente atrás.',
        ],
        asanaTarget: 'El Camello',
      ),
    ],
  ),

  // ==========================================
  // MÓDULO 4: EQUILIBRIO Y FOCO BALI
  // ==========================================
  Module(
    id: 'm4',
    title: 'Módulo 4: Equilibrio y Foco Bali',
    description: 'Posturas de equilibrio avanzado, control del centro corporal y torsiones espinales.',
    iconName: 'psychology',
    lessons: [
      Lesson(
        id: 'l14',
        title: 'Equilibrio Flotante Lateral',
        subtitle: 'Ardha Chandrasana (La Media Luna)',
        category: 'Equilibrio Avanzado',
        readTime: '8 min de lectura',
        overview: 'Postura de equilibrio lateral sobre una pierna y una mano, abriendo el pecho y la cadera hacia el costado.',
        philosophyAndOrigin:
            'Representa la energía lunar (Chandra), fresca, receptiva y equilibrante.',
        biomechanicsAndAlignment:
            'Abducción de la cadera flotante con activación intensa del glúteo medio. El torso se mantiene extendido en un solo plano.',
        pranayamaAndEnergy:
            'Respiración fluida Ujjayi para estabilizar el equilibrio.',
        drishtiAndFocus:
            'Mirada hacia el suelo (principiante) o hacia la mano superior elevada (avanzado).',
        keyPoints: [
          'Apoya la mano inferior sobre un bloque situado a 20 cm por delante del pie.',
          'Eleva la pierna trasera paralela al suelo con el pie en flexión.',
          'Abre el hombro superior alineándolo sobre el inferior.',
        ],
        commonErrors: [
          'Dejar caer la pierna trasera por debajo de la línea de la cadera.',
          'Cerrar el pecho girando el torso hacia el suelo.',
        ],
        safetyAndLimits: [
          'Utilizar siempre un bloque debajo de la mano base si no se alcanza el suelo con la columna recta.',
        ],
        variations: [
          'Principiante: Realizar con la espalda apoyada contra una pared.',
          'Avanzado: Despegar la mano del suelo manteniendo el equilibrio solo en la pierna base.',
        ],
        asanaTarget: 'La Media Luna',
      ),
      Lesson(
        id: 'l15',
        title: 'Fortalecimiento de la V Abdominal',
        subtitle: 'Navasana (El Barco)',
        category: 'Fuerza de Core',
        readTime: '6 min de lectura',
        overview: 'Postura en V sentada sobre los isquiones que exige máxima contracción del abdomen y flexores de cadera.',
        philosophyAndOrigin:
            'Representa a una barca sorteando las olas del océano, enseñando estabilidad en la inestabilidad.',
        biomechanicsAndAlignment:
            'Contracción isotónica del recto abdominal, psoas ilíaco y recto femoral. La columna se mantiene erguida.',
        pranayamaAndEnergy:
            'Respiración corta e intercostal, manteniendo el abdomen firme.',
        drishtiAndFocus:
            'Angustha Ma Dyai Drishti: Mirada fija a los dedos gordos de los pies.',
        keyPoints: [
          'Equilibrate justo sobre los isquiones, evitando rodar hacia el sacro.',
          'Eleva el esternón manteniendo el pecho abierto.',
          'Extiende las piernas a 45° o mantenlas flexionadas en 90°.',
        ],
        commonErrors: [
          'Encorvar la espalda perdiendo la forma de V y cargando las lumbares.',
          'Aguantar la respiración (apnea).',
        ],
        safetyAndLimits: [
          'En caso de molestias en la espalda baja, flexionar las rodillas a 90° y sujetar los muslos por detrás.',
        ],
        variations: [
          'Principiante: Rodillas flexionadas con tibias paralelas al suelo.',
          'Avanzado: Piernas completamente estiradas con brazos extendidos a los lados.',
        ],
        asanaTarget: 'El Barco',
      ),
      Lesson(
        id: 'l16',
        title: 'Elevación Pélvica y Cadena Posterior',
        subtitle: 'Setu Bandhasana (El Puente)',
        category: 'Extensión y Fuerza Posterior',
        readTime: '7 min de lectura',
        overview: 'Elevación de pelvis desde posición supina que fortalece glúteos, isquiotibiales y flexibiliza la columna.',
        philosophyAndOrigin:
            'Construye un puente de conexión entre la tierra y el cielo, la mente y el cuerpo.',
        biomechanicsAndAlignment:
            'Fuerte activación de glúteo mayor y semitendinoso. Extensión de la cadera con apertura del pecho.',
        pranayamaAndEnergy:
            'Inhalaciones que expanden la caja torácica hacia la barbilla (Jalandhara Bandha espontáneo).',
        drishtiAndFocus:
            'Nabi Chakra Drishti: Mirada hacia el pecho o el ombligo.',
        keyPoints: [
          'Coloca los pies alineados al ancho de las caderas con los talones cerca de los glúteos.',
          'Presiona firmemente las plantas de los pies para elevar la pelvis.',
          'Entrelaza las manos por debajo de la espalda juntando los hombros.',
        ],
        commonErrors: [
          'Abrir las rodillas hacia los lados perdiendo la alineación paralela.',
          'Girar la cabeza hacia los lados mientras se sostiene la postura.',
        ],
        safetyAndLimits: [
          'Nunca girar el cuello hacia los lados durante la elevación para proteger las cervicales.',
        ],
        variations: [
          'Principiante: Puente asistido colocando un bloque bajo el sacro.',
          'Avanzado: Elevar una pierna recta hacia el cielo (Eka Pada Setu Bandhasana).',
        ],
        asanaTarget: 'El Puente',
      ),
      Lesson(
        id: 'l17',
        title: 'Torsión Espinal y Movilidad Axial',
        subtitle: 'Ardha Matsyendrasana (Señor de los Peces)',
        category: 'Torsiones Espinales',
        readTime: '7 min de lectura',
        overview: 'Torsión de columna sentada que masajea los órganos abdominales y flexibiliza las vértebras.',
        philosophyAndOrigin:
            'Dedicada al sabio Matsyendra, quien aprendió yoga escuchando a Shiva en las profundidades del océano.',
        biomechanicsAndAlignment:
            'Rotación axial de las vértebras dorsales y lumbares sostenida por los oblicuos y multífidos.',
        pranayamaAndEnergy:
            'Inhala alargando la columna hacia arriba; exhala profundizando la torsión desde el ombligo.',
        drishtiAndFocus:
            'Mirada dirigida por encima del hombro trasero.',
        keyPoints: [
          'Mantén ambos isquiones firmemente apoyados en el suelo.',
          'Abraza la rodilla flexionada con el brazo contrario o cruza el codo por fuera.',
          'Crece a lo largo de la columna antes de girar.',
        ],
        commonErrors: [
          'Colapsar el tronco atrás inclinándose sobre la mano posterior.',
          'Forzar la torsión con los brazos en lugar de rotar desde la musculatura del core.',
        ],
        safetyAndLimits: [
          'En caso de hernia discal activa, realizar torsiones muy suaves sin forzar el palanqueo.',
        ],
        variations: [
          'Principiante: Mantener la pierna inferior estirada en el suelo.',
          'Avanzado: Realizar un enganche de manos por detrás de la espalda (Bind).',
        ],
        asanaTarget: 'Señor de los Peces',
      ),
    ],
  ),

  // ==========================================
  // MÓDULO 5: SECUENCIAS DE VINYASA FLOW
  // ==========================================
  Module(
    id: 'm5',
    title: 'Módulo 5: Secuencias de Vinyasa Flow',
    description: 'Enlaza posturas dinámicas al ritmo de la respiración para generar calor y resistencia.',
    iconName: 'wb_sunny',
    lessons: [
      Lesson(
        id: 'l18',
        title: 'Secuencia Dinámica de Calentamiento',
        subtitle: 'Surya Namaskar A (Saludo al Sol A)',
        category: 'Vinyasa Flow',
        readTime: '8 min de lectura',
        overview: 'La secuencia madre del yoga dinámico que coordina 9 movimientos con la respiración.',
        philosophyAndOrigin:
            'Rito ancestral de reverencia al sol como fuente de vida, luz y conciencia divina.',
        biomechanicsAndAlignment:
            'Transición continua entre flexiones de columna, planchas y extensiones como Cobra o Perro Boca Arriba.',
        pranayamaAndEnergy:
            'Sincronización exacta: 1 movimiento = 1 inhalación o exhalación Ujjayi.',
        drishtiAndFocus:
            'Giro continuo de Drishti correspondiente a cada asana de la secuencia.',
        keyPoints: [
          'Coordina cada paso con el inicio de la respiración.',
          'Mantén la estabilidad del core en las transiciones de Plancha a Chaturanga.',
          'Sostén 5 respiraciones completas en Perro Boca Abajo.',
        ],
        commonErrors: [
          'Moverse más rápido que la respiración perdiendo el ritmo.',
          'Dejar caer la pelvis en Chaturanga.',
        ],
        safetyAndLimits: [
          'Adaptar las bajadas apoyando rodillas en el suelo si falta fuerza en los tríceps.',
        ],
        variations: [
          'Principiante: Saludo al sol modificado con Cobra y rodillas en suelo.',
          'Avanzado: Transiciones con saltos flotados entre Uttanasana y Chaturanga.',
        ],
        asanaTarget: 'La Plancha',
      ),
      Lesson(
        id: 'l19',
        title: 'Flujo de Fuerza e Intensidad',
        subtitle: 'Surya Namaskar B (Saludo al Sol B)',
        category: 'Vinyasa Flow',
        readTime: '9 min de lectura',
        overview: 'Variante avanzada que incorpora La Silla y Guerrero I, elevando la exigencia cardiovascular.',
        philosophyAndOrigin:
            'Profundiza el calor purificador (Tapas) fortaleciendo las piernas y la capacidad pulmonar.',
        biomechanicsAndAlignment:
            'Combina flexiones intensas de rodilla en Utkatasana con zancadas potentes de Guerrero I.',
        pranayamaAndEnergy:
            'Respiración Ujjayi constante y vigorosa para abastecer de oxígeno los grandes grupos musculares.',
        drishtiAndFocus:
            'Atención continua en los puntos de fijación de cada postura.',
        keyPoints: [
          'Inicia con la postura de La Silla (Utkatasana).',
          'Transita fluidamente a Guerrero I con la pierna derecha e izquierda.',
          'Mantén la precisión biomecánica en cada paso.',
        ],
        commonErrors: [
          'Acelerar el paso en Guerrero I para evitar la fatiga muscular.',
          'Perder la alineación de la rodilla delantera.',
        ],
        safetyAndLimits: [
          'Tomar pausas en Balasana (Postura del Niño) si la frecuencia cardíaca se eleva en exceso.',
        ],
        variations: [
          'Principiante: Realizar un solo lado y descansar antes de completar la vuelta.',
          'Avanzado: Sostener 3 respiraciones en cada postura de la secuencia.',
        ],
        asanaTarget: 'La Silla',
      ),
      Lesson(
        id: 'l20',
        title: 'Transición Fluida de Guerrero a Triángulo',
        subtitle: 'Flow Energizante',
        category: 'Vinyasa Flow',
        readTime: '8 min de lectura',
        overview: 'Enlaza de forma continua Guerrero II, Guerrero Invertido y Triángulo en una sola ola de movimiento.',
        philosophyAndOrigin:
            'Enseña a fluir entre la fuerza activa y la apertura expansiva sin rigidez.',
        biomechanicsAndAlignment:
            'Mantiene la base estacada de las piernas mientras el torso se desplaza en diferentes planos.',
        pranayamaAndEnergy:
            'Flujo continuo de Prana guiado por la inhalación al subir y exhalación al descender.',
        drishtiAndFocus:
            'Acompañar con la mirada el movimiento fluido de las manos.',
        keyPoints: [
          'Mantén las piernas firmes y enraizadas mientras el torso se mueve.',
          'Inhala para abrir el pecho hacia atrás en Guerrero Invertido.',
          'Exhala para deslizarte hacia adelante en el Triángulo.',
        ],
        commonErrors: [
          'Mover los pies durante las transiciones perdiendo la base sólida.',
          'Perder la flexión de 90° en la rodilla delantera al ir atrás.',
        ],
        safetyAndLimits: [
          'Ajustar la apertura de piernas si se genera molestia en la ingle o cadera.',
        ],
        variations: [
          'Principiante: Hacer pausas de 2 respiraciones en cada postura.',
          'Avanzado: Fluir a ritmo de 1 respiración por movimiento sin pausas.',
        ],
        asanaTarget: 'El Guerrero II',
      ),
    ],
  ),

  // ==========================================
  // MÓDULO 6: DESCANSO Y RESTAURATIVO
  // ==========================================
  Module(
    id: 'm6',
    title: 'Módulo 6: Descanso y Restaurativo',
    description: 'Posturas pasivas de descarga, liberación miofascial y relajación profunda estilo Bali.',
    iconName: 'nights_stay',
    lessons: [
      Lesson(
        id: 'l21',
        title: 'Descarga Cervical y Dorsal',
        subtitle: 'Alivio de Espalda',
        category: 'Yoga Restaurativo',
        readTime: '6 min de lectura',
        overview: 'Movimientos suaves e inclinaciones pasivas diseñadas para liberar la tensión acumulada en el cuello.',
        philosophyAndOrigin:
            'Cultiva la rendición y el autocuidado pasivo, calmando el sistema nervioso parasimpático.',
        biomechanicsAndAlignment:
            'Movilidades suaves en flexión y extensión neutra sin carga muscular activa.',
        pranayamaAndEnergy:
            'Respiración diafragmática profunda y pausada.',
        drishtiAndFocus:
            'Ojos cerrados o mirada suave enfocada internamente.',
        keyPoints: [
          'Realiza todos los movimientos de forma pausada.',
          'Usa soportes como mantas o cojines debajo de las articulaciones.',
          'Permite que la gravedad abra el cuerpo sin forzar.',
        ],
        commonErrors: [
          'Forzar los estiramientos con tirones bruscos.',
          'Mantener tensión en la mandíbula o el entrecejo.',
        ],
        safetyAndLimits: [
          'Apto para todas las personas. Detener si surge cualquier pinchazo agudo.',
        ],
        variations: [
          'Principiante: Realizar totalmente tumbado en la esterilla.',
          'Avanzado: Aumentar la permanencia en la postura hasta 5 minutos.',
        ],
        asanaTarget: 'La Cobra',
      ),
      Lesson(
        id: 'l22',
        title: 'Apertura Pasiva de Caderas Nocturna',
        subtitle: 'Relajación Nocturna',
        category: 'Yoga Restaurativo',
        readTime: '6 min de lectura',
        overview: 'Posturas tumbadas sosteniendo la apertura de cadera para desacelerar el pulso antes de dormir.',
        philosophyAndOrigin:
            'Inspirado en el descanso pacífico de Bali, preparando el cuerpo para un sueño reparador.',
        biomechanicsAndAlignment:
            'Relajación total de los aductores y psoas sostenidos por el suelo o soportes.',
        pranayamaAndEnergy:
            'Respiración Chandra Bhedana (respiración lunar por el orificio nasal izquierdo) para inducir la calma.',
        drishtiAndFocus:
            'Ojos cerrados llevando la atención al espacio del corazón.',
        keyPoints: [
          'Túmbate boca arriba y junta las plantas de los pies.',
          'Coloca mantas bajo las rodillas si sientes tirantez.',
          'Reposa las manos sobre el abdomen sientiendo el movimiento respiratorio.',
        ],
        commonErrors: [
          'Dejar las piernas suspendidas en el aire con tensión.',
        ],
        safetyAndLimits: [
          'Si hay molestia en la zona lumbar, colocar un cojín debajo de la espalda baja.',
        ],
        variations: [
          'Principiante: Colocar soportes altos bajo los muslos.',
          'Avanzado: Permanecer en la postura en completa quietud durante 10 minutos.',
        ],
        asanaTarget: 'La Mariposa',
      ),
    ],
  ),
];

// Alias para garantizar compatibilidad con el resto de la aplicación
final List<Module> academyModules = sampleModules;