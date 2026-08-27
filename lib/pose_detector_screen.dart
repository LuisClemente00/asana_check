// Archivo: pose_detector_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart' show WriteBuffer, debugPrint;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:keep_screen_on/keep_screen_on.dart';
import 'academy_progress_service.dart';

import 'pose_result_screen.dart';

class PoseDetectorScreen extends StatefulWidget {
  final String asanaName;
  final Function(int secondsSpent)? onPoseCompleted;

  const PoseDetectorScreen({
    super.key,
    required this.asanaName,
    this.onPoseCompleted,
  });

  @override
  State<PoseDetectorScreen> createState() => _PoseDetectorScreenState();
}

class _PoseDetectorScreenState extends State<PoseDetectorScreen> {
  CameraController? _controller;
  bool _isPermissionGranted = false;
  late FlutterTts _flutterTts;

  late AudioPlayer _audioPlayer;
  bool _isMusicPlaying = false;

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  bool _isProcessing = false;
  Timer? _timer;
  Timer? _voiceGraceTimer;

  static const int _poseDuration = 30;
  int _secondsRemaining = _poseDuration;

  bool _isCompleted = false;

  bool _isRightSide = true;
  bool _hasSwitchedToLeft = false;

  String _feedbackMessage = "Colócate frente a la cámara de cuerpo entero...";
  bool _isAlignmentCorrect = false;
  DateTime? _lastSpeechTime;

  int _currentStep = 0;
  bool _showImagePreview = true;

  final Map<String, List<String>> _asanaSteps = {
    "El Árbol": [
      "Pie de apoyo firme en el suelo.",
      "Eleva la planta del pie contrario al muslo o pantorrilla.",
      "Junta las palmas al pecho o sobre la cabeza.",
    ],
    "Perro Boca Abajo": [
      "Manos firmes abiertas al ancho de hombros.",
      "Eleva la cadera hacia el techo.",
      "Empuja el suelo alargando la espalda.",
    ],
    "El Guerrero II": [
      "Piernas ampliamente separadas.",
      "Flexiona la rodilla delantera a 90 grados.",
      "Brazos extendidos en cruz a la altura de los hombros.",
    ],
    "La Plancha": [
      "Cuerpo alineado en una tabla recta.",
      "Manos bajo la vertical de los hombros.",
      "Core y glúteos fuertemente activados.",
    ],
    "El Triángulo": [
      "Separa piernas e inclina el torso lateralmente.",
      "Mano inferior a la espinilla o tobillo.",
      "Brazo superior apuntando al cielo abriendo el pecho.",
    ],
    "La Cobra": [
      "Túmbate boca abajo con manos bajo los hombros.",
      "Presiona el empeine contra el suelo.",
      "Eleva suavemente el pecho sin colapsar el cuello.",
    ],
    "La Silla": [
      "Pies juntos o al ancho de caderas.",
      "Flexiona rodillas bajando la cadera como al sentarte.",
      "Eleva ambos brazos junto a las orejas.",
    ],
    "El Guerrero I": [
      "Da un paso largo atrás con una pierna.",
      "Flexiona la rodilla delantera.",
      "Eleva brazos extendidos rotando la cadera al frente.",
    ],
    "La Media Luna": [
      "Apoya una mano en el suelo y eleva la pierna trasera.",
      "Abre cadera y pecho lateralmente.",
      "Extiende el brazo superior al cielo.",
    ],
    "El Puente": [
      "Túmbate boca arriba con rodillas flexionadas.",
      "Eleva la cadera despegando la espalda del suelo.",
      "Presiona los pies contra la esterilla.",
    ],
    "El Guerrero III": [
      "Equilibrio sobre una pierna estirada.",
      "Torso e pierna trasera paralelos al suelo.",
      "Brazos extendidos hacia adelante o al pecho.",
    ],
    "La Pinza de Pie": [
      "Pies juntos y piernas estiradas.",
      "Flexiónate desde la cadera llevando el torso abajo.",
      "Relaja cuello y cabeza hacia las espinillas.",
    ],
    "El Camello": [
      "De rodillas en el suelo.",
      "Lleva manos a tobillos empujando la pelvis al frente.",
      "Abre el pecho hacia el cielo.",
    ],
    "Señor de los Peces": [
      "Sentado con una pierna cruzada sobre la otra.",
      "Gira el torso abrazando la rodilla elevada.",
      "Mantiene la columna erguida.",
    ],
    "La Paloma": [
      "Flexiona una pierna adelante y estira la otra atrás.",
      "Cadera alineada hacia el suelo.",
      "Apertura profunda de cadera.",
    ],
    "La Mariposa": [
      "Sentado con plantas de los pies juntas.",
      "Deja caer las rodillas hacia los lados.",
      "Alarga la columna y relaja caderas.",
    ],
    "Guerrero Humilde": [
      "Desde Guerrero I, entrelaza manos a la espalda.",
      "Declina el torso por el interior de la rodilla delantera.",
      "Eleva los brazos estirados.",
    ],
    "El Barco": [
      "Sentado sobre los isquiones.",
      "Eleva piernas en diagonal y reclinando el torso.",
      "Brazos extendidos hacia adelante.",
    ],
  };

  String _getPoseAssetPath(String name) {
    final sanitized = name
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
    return 'assets/asanas/$sanitized.png';
  }

  @override
  void initState() {
    super.initState();
    KeepScreenOn.turnOn();
    _initTts();
    _initBackgroundMusic();
    _checkPermissionAndInitCamera();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("es-ES");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _restoreMusicVolume();
    });
  }

  Future<void> _initBackgroundMusic() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.play(AssetSource('bali_ambient.mp3'));
      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      debugPrint("Error al reproducir música de ambiente: $e");
    }
  }

  Future<void> _duckMusicVolume() async {
    if (_isMusicPlaying) {
      await _audioPlayer.setVolume(0.15);
    }
  }

  Future<void> _restoreMusicVolume() async {
    if (_isMusicPlaying) {
      await _audioPlayer.setVolume(0.5);
    }
  }

  Future<void> _speak(String text, {bool force = false}) async {
    final now = DateTime.now();
    if (force ||
        _lastSpeechTime == null ||
        now.difference(_lastSpeechTime!).inSeconds >= 4) {
      _lastSpeechTime = now;
      await _duckMusicVolume();
      await _flutterTts.speak(text);
    }
  }

  Future<void> _checkPermissionAndInitCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      _initializeCamera();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se necesita permiso de cámara para el análisis de pose.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      await _controller!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error al inicializar la cámara nativa: $e");
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _isCompleted) return;
    _isProcessing = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final imageRotation = InputImageRotation.rotation270deg;
      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );

      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        _analyzePoseReal(poses.first);
      } else {
        setState(() {
          _isAlignmentCorrect = false;
          _feedbackMessage = "Buscando tu cuerpo. Aléjate un poco más.";
        });
      }
    } catch (e) {
      debugPrint("Error en el procesado: $e");
    } finally {
      _isProcessing = false;
    }
  }

  double _calculateAngle(
    PoseLandmark first,
    PoseLandmark second,
    PoseLandmark third,
  ) {
    double radians =
        math.atan2(third.y - second.y, third.x - second.x) -
        math.atan2(first.y - second.y, first.x - second.x);
    double angle = (radians * 180.0 / math.pi).abs();
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }

  void _analyzePoseReal(Pose pose) {
    // 1. OBTENER Y VALIDAR PUNTOS CLAVE (confianza > 0.65)
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final lElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    bool isReliable(PoseLandmark? lm) => lm != null && lm.likelihood > 0.65;

    bool bodyVisible = isReliable(rShoulder) &&
        isReliable(lShoulder) &&
        isReliable(rHip) &&
        isReliable(lHip) &&
        isReliable(rKnee) &&
        isReliable(lKnee) &&
        isReliable(rAnkle) &&
        isReliable(lAnkle);

    if (!bodyVisible) {
      _handleAlignment(
        correct: false,
        message: "Ponte a una distancia donde la cámara vea todo tu cuerpo.",
        speech: "Aléjate hasta que se vean tus pies y tus hombros.",
      );
      return;
    }

    // Puntos de trabajo según lado (derecho / izquierdo)
    final standingHip = _isRightSide ? rHip! : lHip!;
    final standingKnee = _isRightSide ? rKnee! : lKnee!;
    final standingAnkle = _isRightSide ? rAnkle! : lAnkle!;
    final standingShoulder = _isRightSide ? rShoulder! : lShoulder!;

    final bentHip = _isRightSide ? lHip! : rHip!;
    final bentKnee = _isRightSide ? lKnee! : rKnee!;
    final bentAnkle = _isRightSide ? lAnkle! : rAnkle!;

    // 2. EVALUACIÓN GEOMÉTRICA SEGÚN POSTURA REAL

    switch (widget.asanaName) {
      case 'El Árbol':
        // 1. Pierna de apoyo estirada (ángulo cercano a 180°)
        double standingLegAngle = _calculateAngle(standingHip, standingKnee, standingAnkle);
        bool isStandingLegStraight = standingLegAngle >= 152;

        // 2. Pierna doblada flexionada (ángulo entre 40° y 130°)
        double bentLegAngle = _calculateAngle(bentHip, bentKnee, bentAnkle);
        bool isKneeBent = bentLegAngle >= 40 && bentLegAngle <= 130;

        // 3. Zonas seguras para el pie (evitando apoyar directamente en la rodilla)
        const double kneeSafetyMargin = 18.0; 

        // Zona Pantorrilla (debajo de la rodilla)
        bool isFootInCalf = bentAnkle.y > (standingKnee.y + kneeSafetyMargin);

        // Zona Muslo (encima de la rodilla)
        bool isFootInThigh = bentAnkle.y < (standingKnee.y - kneeSafetyMargin);

        // Es válido si se apoya en el muslo O en la pantorrilla
        bool isFootPlacementSafe = isFootInCalf || isFootInThigh;

        if (!isStandingLegStraight) {
          _handleAlignment(
            correct: false,
            message: "Mantén la pierna de apoyo completamente estirada.",
            speech: "Estira la pierna de apoyo.",
          );
        } else if (!isKneeBent) {
          _handleAlignment(
            correct: false,
            message: "Flexiona la otra pierna abriendo la rodilla a un lado.",
            speech: "Abre la rodilla hacia un lado.",
          );
        } else if (!isFootPlacementSafe) {
          _handleAlignment(
            correct: false,
            message: "Apoya el pie en el muslo (arriba) o pantorrilla (abajo), nunca sobre la rodilla.",
            speech: "Mueve el pie fuera de la rodilla.",
          );
        } else {
          String positionText = isFootInThigh ? "en el muslo" : "en la pantorrilla";
          _handleAlignment(
            correct: true,
            message: "¡Árbol perfecto $positionText! Mantén el equilibrio.",
            speech: "Excelente equilibrio.",
          );
        }
        break;

      case 'El Guerrero II':
      case 'El Guerrero':
        double frontKneeAngle = _calculateAngle(standingHip, standingKnee, standingAnkle);
        double backKneeAngle = _calculateAngle(bentHip, bentKnee, bentAnkle);

        bool isFrontKneeCorrect = frontKneeAngle >= 75 && frontKneeAngle <= 120;
        bool isBackLegStraight = backKneeAngle >= 145;

        if (isFrontKneeCorrect && isBackLegStraight) {
          _handleAlignment(
            correct: true,
            message: "¡Guerrero II perfecto!",
            speech: "Guerrero dos alineado.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Flexiona la rodilla delantera a 90° y estira la trasera.",
            speech: "Flexiona la pierna de adelante y estira la de atrás.",
          );
        }
        break;

      case 'La Silla':
        double kneeAngleR = _calculateAngle(rHip!, rKnee!, rAnkle!);
        double kneeAngleL = _calculateAngle(lHip!, lKnee!, lAnkle!);
        
        // Ambas rodillas deben estar flexionadas (entre 80° y 130°)
        bool kneesBent = (kneeAngleR >= 80 && kneeAngleR <= 135) && 
                         (kneeAngleL >= 80 && kneeAngleL <= 135);
        // Las muñecas deben estar por encima de la cabeza/hombros
        bool armsUp = (rWrist != null && rWrist.y < rShoulder!.y) &&
                       (lWrist != null && lWrist.y < lShoulder!.y);

        if (kneesBent && armsUp) {
          _handleAlignment(
            correct: true,
            message: "¡Silla correcta! Aguanta la posición.",
            speech: "Buena postura de la silla.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Baja la cadera flexionando rodillas y sube los brazos.",
            speech: "Flexiona rodillas y eleva ambos brazos.",
          );
        }
        break;

      case 'La Pinza de Pie':
        // Ángulo cadera-hombro-rodilla (flexión profunda de torso)
        double hipFoldAngle = _calculateAngle(rShoulder!, rHip!, rKnee!);
        
        if (hipFoldAngle <= 80) {
          _handleAlignment(
            correct: true,
            message: "¡Pinza profunda! Buena flexión de columna.",
            speech: "Excelente flexión hacia adelante.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Baja el torso llevando las manos hacia los pies.",
            speech: "Inclínate más hacia adelante desde la cadera.",
          );
        }
        break;

      case 'La Plancha':
        // Hombro, cadera y tobillo alineados en horizontal (ángulo cercano a 180°)
        double bodyLineAngle = _calculateAngle(standingShoulder, standingHip, standingAnkle);
        bool isHorizontal = (standingHip.y - standingShoulder.y).abs() < 120;

        if (bodyLineAngle >= 155 && isHorizontal) {
          _handleAlignment(
            correct: true,
            message: "¡Plancha recta! Activa el abdomen.",
            speech: "Plancha bien alineada.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Mantén el cuerpo en una línea recta horizontal.",
            speech: "Alinea cadera y hombros en tabla.",
          );
        }
        break;

      case 'Perro Boca Abajo':
        // Cadera es el punto más alto (Y menor que hombros y tobillos)
        bool hipsElevated = (rHip!.y < rShoulder!.y - 20) && (rHip.y < rAnkle!.y - 20);

        if (hipsElevated) {
          _handleAlignment(
            correct: true,
            message: "¡Perro Boca Abajo alineado! Cadera al techo.",
            speech: "Buena V invertida.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Eleva la cadera hacia el techo formando una 'V' invertida.",
            speech: "Empuja el suelo y sube la cadera.",
          );
        }
        break;

      case 'Guerrero Humilde':
        double humbleFold = _calculateAngle(standingShoulder, standingHip, standingKnee);
        if (humbleFold <= 100) {
          _handleAlignment(
            correct: true,
            message: "¡Guerrero Humilde alineado!",
            speech: "Guerrero Humilde bien ejecutado.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Inclina el torso por el interior de tu rodilla.",
            speech: "Baja el torso por dentro de la pierna.",
          );
        }
        break;

      default:
        // Exige que las muñecas o la cadera se muevan respecto a los hombros
        bool notJustStandingStill = false;

        if (rShoulder != null && lShoulder != null && rHip != null) {
          bool armsUp = (rWrist != null && rWrist.y < rShoulder.y) ||
                        (lWrist != null && lWrist.y < lShoulder.y);
          bool isCrouchingOrLying = rHip.y > rShoulder.y + 150;

          notJustStandingStill = armsUp || isCrouchingOrLying;
        }

        if (notJustStandingStill) {
          _handleAlignment(
            correct: true,
            message: "Postura detectada. Mantén la posición...",
            speech: "Mantén la postura.",
          );
        } else {
          _handleAlignment(
            correct: false,
            message: "Adopta la forma de la postura para comenzar.",
            speech: "Realiza el gesto de la postura.",
          );
        }
        break;
    }
  }

  void _handleAlignment({
    required bool correct,
    required String message,
    required String speech,
  }) {
    setState(() {
      _isAlignmentCorrect = correct;
      _feedbackMessage = message;
    });

    if (correct) {
      _startPoseCountdown();
      _voiceGraceTimer?.cancel();
      _voiceGraceTimer = null;
    } else {
      _stopPoseCountdown();
      if (_voiceGraceTimer == null && speech.isNotEmpty) {
        _voiceGraceTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted && !_isAlignmentCorrect) {
            _speak(speech);
          }
          _voiceGraceTimer = null;
        });
      }
    }
  }

  void _startPoseCountdown() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isAlignmentCorrect) {
        setState(() {
          if (_secondsRemaining > 1) {
            _secondsRemaining--;
            if (_secondsRemaining == 15) {
              _speak("Vas a mitad de camino, respira profundo.");
            }
          } else {
            _timer?.cancel();
            _timer = null;

            if (!_hasSwitchedToLeft) {
              _hasSwitchedToLeft = true;
              _isRightSide = false;
              _secondsRemaining = _poseDuration;
              _isAlignmentCorrect = false;
              _feedbackMessage =
                  "¡Lado derecho completado! Cambia al izquierdo...";
              _speak(
                "Excelente. Ahora cambia de lado y repite la postura en el lado izquierdo.",
                force: true,
              );
            } else {
              _secondsRemaining = 0;
              _isCompleted = true;
              // CAMBIO AQUÍ: Solo reproducimos este mensaje largo si NO estamos en una secuencia
              if (widget.onPoseCompleted == null) {
                _speak(
                  "Excelente. Sesión completada con éxito en ambos lados.",
                  force: true,
                );
              }
              _finishWorkoutSuccess();
            }
          }
        });
      } else {
        _stopPoseCountdown();
      }
    });
  }

  void _stopPoseCountdown() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void _finishWorkoutSuccess() async {
    _audioPlayer.stop();
    await AcademyProgressService.completeLesson(widget.asanaName);

    if (widget.onPoseCompleted != null) {
      // MODO SECUENCIA: Transición inmediata a la siguiente postura sin pausas ni pantallas intermadias
      _speak("¡Muy bien! Siguiente postura.", force: true);
      widget.onPoseCompleted!(60);
    } else {
      // MODO POSTURA SUELTA: Feedback de fin de sesión y pantalla de resultados
      _speak(
        "Excelente. Sesión completada con éxito en ambos lados.",
        force: true,
      );
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PoseResultScreen(
                asanaName: widget.asanaName,
                secondsTrained: 60,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    KeepScreenOn.turnOff();
    _timer?.cancel();
    _voiceGraceTimer?.cancel();
    _controller?.dispose();
    _poseDetector.close();
    _flutterTts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  // CÁMARA SIN DISTORSIÓN / ESTIRAMIENTO
  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2D5AC8)),
      );
    }

    final mediaSize = MediaQuery.of(context).size;
    final double cameraAspectRatio = _controller!.value.aspectRatio;
    double scale = 1 / (cameraAspectRatio * mediaSize.aspectRatio);

    if (scale < 1) scale = 1 / scale;

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    double progress = _secondsRemaining / _poseDuration.toDouble();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              _isCompleted
                  ? Colors.green
                  : (_isAlignmentCorrect
                      ? const Color(0xFF2D5AC8)
                      : Colors.orangeAccent),
            ),
          ),
        ),
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _isCompleted
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 50,
                  )
                : Text(
                    "$_secondsRemaining",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: _isAlignmentCorrect
                          ? const Color(0xFF2D5AC8)
                          : Colors.orangeAccent,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoseImagePreview() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showImagePreview = !_showImagePreview;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _showImagePreview ? 100 : 44,
        height: _showImagePreview ? 130 : 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white38, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _showImagePreview
              ? Stack(
                  children: [
                    Image.asset(
                      _getPoseAssetPath(widget.asanaName),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.accessibility_new_rounded,
                                  color: Colors.white54, size: 36),
                              SizedBox(height: 4),
                              Text(
                                "Foto Asana",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                )
              : const Icon(
                  Icons.image_outlined,
                  color: Colors.white,
                  size: 24,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _asanaSteps[widget.asanaName] ?? ["Mantén la postura e inhala profundo."];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          Container(color: Colors.black.withValues(alpha: 0.2)),

          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "Paso ${_currentStep + 1} / ${steps.length}:",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps[_currentStep < steps.length ? _currentStep : 0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: PoseGuidePainter(
                asanaName: widget.asanaName,
                isAligned: _isAlignmentCorrect,
                isRightSide: _isRightSide,
              ),
            ),
          ),

          Positioned(
            top: 165,
            right: 20,
            child: _buildPoseImagePreview(),
          ),

          Positioned(
            top: 45,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.asanaName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isRightSide ? Colors.blue.shade700 : Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isRightSide ? "LADO DERECHO" : "LADO IZQUIERDO",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isAlignmentCorrect ? Colors.green : Colors.orangeAccent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAlignmentCorrect
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: _isAlignmentCorrect
                            ? Colors.green
                            : Colors.orangeAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _feedbackMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTimerWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// TODAS LAS 18 ASANAS DEFINIDAS COMPLETAS (SIN RECORTAR)
// ========================================================
class PoseGuidePainter extends CustomPainter {
  final String asanaName;
  final bool isAligned;
  final bool isRightSide;

  PoseGuidePainter({
    required this.asanaName,
    required this.isAligned,
    required this.isRightSide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAligned
          ? Colors.green.withValues(alpha: 0.8)
          : Colors.orangeAccent.withValues(alpha: 0.8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    Map<String, Offset> points = {};
    double sideMult = isRightSide ? 1.0 : -1.0;

    switch (asanaName) {
      case 'El Árbol':
        points = {
          'head': Offset(cx, cy - 180),
          'neck': Offset(cx, cy - 140),
          'rShoulder': Offset(cx - 35, cy - 130),
          'lShoulder': Offset(cx + 35, cy - 130),
          'rElbow': Offset(cx - 40, cy - 170),
          'lElbow': Offset(cx + 40, cy - 170),
          'rWrist': Offset(cx, cy - 210),
          'lWrist': Offset(cx, cy - 210),
          'rHip': Offset(cx - 20, cy - 30),
          'lHip': Offset(cx + 20, cy - 30),
          'rKnee': Offset(cx - (20 * sideMult), cy + 70),
          'lKnee': Offset(cx + (80 * sideMult), cy + 20),
          'rAnkle': Offset(cx - (20 * sideMult), cy + 170),
          'lAnkle': Offset(cx + (15 * sideMult), cy + 30),
        };
        break;

      case 'El Guerrero II':
      case 'El Guerrero':
        points = {
          'head': Offset(cx, cy - 140),
          'neck': Offset(cx, cy - 100),
          'rShoulder': Offset(cx - 40, cy - 90),
          'lShoulder': Offset(cx + 40, cy - 90),
          'rElbow': Offset(cx - 100, cy - 90),
          'lElbow': Offset(cx + 100, cy - 90),
          'rWrist': Offset(cx - 150, cy - 90),
          'lWrist': Offset(cx + 150, cy - 90),
          'rHip': Offset(cx - 25, cy + 10),
          'lHip': Offset(cx + 25, cy + 10),
          'rKnee': Offset(cx - (90 * sideMult), cy + 70),
          'lKnee': Offset(cx + (80 * sideMult), cy + 80),
          'rAnkle': Offset(cx - (90 * sideMult), cy + 140),
          'lAnkle': Offset(cx + (130 * sideMult), cy + 140),
        };
        break;

      case 'Guerrero Humilde':
        points = {
          'head': Offset(cx - (100 * sideMult), cy + 70),
          'neck': Offset(cx - (70 * sideMult), cy + 30),
          'rShoulder': Offset(cx - (60 * sideMult), cy + 10),
          'lShoulder': Offset(cx - (60 * sideMult), cy + 10),
          'rElbow': Offset(cx - (10 * sideMult), cy - 40),
          'lElbow': Offset(cx - (10 * sideMult), cy - 40),
          'rWrist': Offset(cx + (30 * sideMult), cy - 80),
          'lWrist': Offset(cx + (30 * sideMult), cy - 80),
          'rHip': Offset(cx, cy + 10),
          'lHip': Offset(cx, cy + 10),
          'rKnee': Offset(cx - (80 * sideMult), cy + 80),
          'lKnee': Offset(cx + (70 * sideMult), cy + 70),
          'rAnkle': Offset(cx - (80 * sideMult), cy + 150),
          'lAnkle': Offset(cx + (120 * sideMult), cy + 140),
        };
        break;

      case 'La Plancha':
        points = {
          'head': Offset(cx - (160 * sideMult), cy - 60),
          'neck': Offset(cx - (130 * sideMult), cy - 40),
          'rShoulder': Offset(cx - (110 * sideMult), cy - 30),
          'lShoulder': Offset(cx - (110 * sideMult), cy - 30),
          'rElbow': Offset(cx - (110 * sideMult), cy + 30),
          'lElbow': Offset(cx - (110 * sideMult), cy + 30),
          'rWrist': Offset(cx - (110 * sideMult), cy + 80),
          'lWrist': Offset(cx - (110 * sideMult), cy + 80),
          'rHip': Offset(cx, cy - 10),
          'lHip': Offset(cx, cy - 10),
          'rKnee': Offset(cx + (80 * sideMult), cy + 20),
          'lKnee': Offset(cx + (80 * sideMult), cy + 20),
          'rAnkle': Offset(cx + (160 * sideMult), cy + 50),
          'lAnkle': Offset(cx + (160 * sideMult), cy + 50),
        };
        break;

      case 'El Triángulo':
        points = {
          'head': Offset(cx - (70 * sideMult), cy - 110),
          'neck': Offset(cx - (50 * sideMult), cy - 80),
          'rShoulder': Offset(cx - (50 * sideMult), cy - 70),
          'lShoulder': Offset(cx - (30 * sideMult), cy - 70),
          'rElbow': Offset(cx - (50 * sideMult), cy - 130),
          'lElbow': Offset(cx - (30 * sideMult), cy - 10),
          'rWrist': Offset(cx - (50 * sideMult), cy - 180),
          'lWrist': Offset(cx - (30 * sideMult), cy + 50),
          'rHip': Offset(cx, cy + 10),
          'lHip': Offset(cx + 30, cy + 10),
          'rKnee': Offset(cx - (40 * sideMult), cy + 90),
          'lKnee': Offset(cx + (70 * sideMult), cy + 90),
          'rAnkle': Offset(cx - (70 * sideMult), cy + 160),
          'lAnkle': Offset(cx + (110 * sideMult), cy + 160),
        };
        break;

      case 'La Cobra':
        points = {
          'head': Offset(cx - (120 * sideMult), cy - 120),
          'neck': Offset(cx - (90 * sideMult), cy - 80),
          'rShoulder': Offset(cx - (70 * sideMult), cy - 60),
          'lShoulder': Offset(cx - (70 * sideMult), cy - 60),
          'rElbow': Offset(cx - (60 * sideMult), cy + 10),
          'lElbow': Offset(cx - (60 * sideMult), cy + 10),
          'rWrist': Offset(cx - (80 * sideMult), cy + 60),
          'lWrist': Offset(cx - (80 * sideMult), cy + 60),
          'rHip': Offset(cx + (20 * sideMult), cy + 50),
          'lHip': Offset(cx + (20 * sideMult), cy + 50),
          'rKnee': Offset(cx + (100 * sideMult), cy + 60),
          'lKnee': Offset(cx + (100 * sideMult), cy + 60),
          'rAnkle': Offset(cx + (170 * sideMult), cy + 60),
          'lAnkle': Offset(cx + (170 * sideMult), cy + 60),
        };
        break;

      case 'La Silla':
        points = {
          'head': Offset(cx + (60 * sideMult), cy - 180),
          'neck': Offset(cx + (40 * sideMult), cy - 140),
          'rShoulder': Offset(cx + 20, cy - 120),
          'lShoulder': Offset(cx + 20, cy - 120),
          'rElbow': Offset(cx + (60 * sideMult), cy - 170),
          'lElbow': Offset(cx + (60 * sideMult), cy - 170),
          'rWrist': Offset(cx + (90 * sideMult), cy - 220),
          'lWrist': Offset(cx + (90 * sideMult), cy - 220),
          'rHip': Offset(cx - (50 * sideMult), cy - 10),
          'lHip': Offset(cx - (50 * sideMult), cy - 10),
          'rKnee': Offset(cx + (20 * sideMult), cy + 60),
          'lKnee': Offset(cx + (20 * sideMult), cy + 60),
          'rAnkle': Offset(cx - (30 * sideMult), cy + 140),
          'lAnkle': Offset(cx - (30 * sideMult), cy + 140),
        };
        break;

      case 'Perro Boca Abajo':
        points = {
          'head': Offset(cx - (60 * sideMult), cy + 30),
          'neck': Offset(cx - (40 * sideMult), cy + 10),
          'rShoulder': Offset(cx - (30 * sideMult), cy - 10),
          'lShoulder': Offset(cx - (30 * sideMult), cy - 10),
          'rElbow': Offset(cx - (70 * sideMult), cy + 40),
          'lElbow': Offset(cx - (70 * sideMult), cy + 40),
          'rWrist': Offset(cx - (110 * sideMult), cy + 90),
          'lWrist': Offset(cx - (110 * sideMult), cy + 90),
          'rHip': Offset(cx, cy - 110),
          'lHip': Offset(cx, cy - 110),
          'rKnee': Offset(cx + (60 * sideMult), cy - 10),
          'lKnee': Offset(cx + (60 * sideMult), cy - 10),
          'rAnkle': Offset(cx + (110 * sideMult), cy + 90),
          'lAnkle': Offset(cx + (110 * sideMult), cy + 90),
        };
        break;

      case 'El Guerrero I':
        points = {
          'head': Offset(cx, cy - 180),
          'neck': Offset(cx, cy - 140),
          'rShoulder': Offset(cx - 20, cy - 120),
          'lShoulder': Offset(cx + 20, cy - 120),
          'rElbow': Offset(cx - 20, cy - 170),
          'lElbow': Offset(cx + 20, cy - 170),
          'rWrist': Offset(cx - 20, cy - 220),
          'lWrist': Offset(cx + 20, cy - 220),
          'rHip': Offset(cx - 15, cy - 10),
          'lHip': Offset(cx + 15, cy - 10),
          'rKnee': Offset(cx - (70 * sideMult), cy + 60),
          'lKnee': Offset(cx + (70 * sideMult), cy + 60),
          'rAnkle': Offset(cx - (70 * sideMult), cy + 130),
          'lAnkle': Offset(cx + (120 * sideMult), cy + 130),
        };
        break;

      case 'La Media Luna':
        points = {
          'head': Offset(cx - (100 * sideMult), cy - 10),
          'neck': Offset(cx - (70 * sideMult), cy - 10),
          'rShoulder': Offset(cx - (70 * sideMult), cy - 10),
          'lShoulder': Offset(cx - (70 * sideMult), cy - 10),
          'rElbow': Offset(cx - (70 * sideMult), cy - 70),
          'lElbow': Offset(cx - (70 * sideMult), cy + 40),
          'rWrist': Offset(cx - (70 * sideMult), cy - 130),
          'lWrist': Offset(cx - (70 * sideMult), cy + 90),
          'rHip': Offset(cx + (20 * sideMult), cy - 10),
          'lHip': Offset(cx + (20 * sideMult), cy - 10),
          'rKnee': Offset(cx + (20 * sideMult), cy + 70),
          'lKnee': Offset(cx + (100 * sideMult), cy - 10),
          'rAnkle': Offset(cx + (20 * sideMult), cy + 150),
          'lAnkle': Offset(cx + (170 * sideMult), cy - 10),
        };
        break;

      case 'El Puente':
        points = {
          'head': Offset(cx - (140 * sideMult), cy + 60),
          'neck': Offset(cx - (110 * sideMult), cy + 50),
          'rShoulder': Offset(cx - (90 * sideMult), cy + 50),
          'lShoulder': Offset(cx - (90 * sideMult), cy + 50),
          'rElbow': Offset(cx - (90 * sideMult), cy + 70),
          'lElbow': Offset(cx - (90 * sideMult), cy + 70),
          'rWrist': Offset(cx - (30 * sideMult), cy + 70),
          'lWrist': Offset(cx - (30 * sideMult), cy + 70),
          'rHip': Offset(cx, cy - 30),
          'lHip': Offset(cx, cy - 30),
          'rKnee': Offset(cx + (90 * sideMult), cy + 10),
          'lKnee': Offset(cx + (90 * sideMult), cy + 10),
          'rAnkle': Offset(cx + (90 * sideMult), cy + 80),
          'lAnkle': Offset(cx + (90 * sideMult), cy + 80),
        };
        break;

      case 'El Guerrero III':
        points = {
          'head': Offset(cx - (160 * sideMult), cy - 10),
          'neck': Offset(cx - (130 * sideMult), cy - 10),
          'rShoulder': Offset(cx - (110 * sideMult), cy - 10),
          'lShoulder': Offset(cx - (110 * sideMult), cy - 10),
          'rElbow': Offset(cx - (150 * sideMult), cy - 10),
          'lElbow': Offset(cx - (150 * sideMult), cy - 10),
          'rWrist': Offset(cx - (190 * sideMult), cy - 10),
          'lWrist': Offset(cx - (190 * sideMult), cy - 10),
          'rHip': Offset(cx, cy - 10),
          'lHip': Offset(cx, cy - 10),
          'rKnee': Offset(cx, cy + 60),
          'lKnee': Offset(cx + (80 * sideMult), cy - 10),
          'rAnkle': Offset(cx, cy + 130),
          'lAnkle': Offset(cx + (160 * sideMult), cy - 10),
        };
        break;

      case 'La Pinza de Pie':
        points = {
          'head': Offset(cx - (20 * sideMult), cy + 110),
          'neck': Offset(cx - (20 * sideMult), cy + 70),
          'rShoulder': Offset(cx - (20 * sideMult), cy + 40),
          'lShoulder': Offset(cx - (20 * sideMult), cy + 40),
          'rElbow': Offset(cx - (20 * sideMult), cy + 90),
          'lElbow': Offset(cx - (20 * sideMult), cy + 90),
          'rWrist': Offset(cx - (20 * sideMult), cy + 130),
          'lWrist': Offset(cx - (20 * sideMult), cy + 130),
          'rHip': Offset(cx, cy - 40),
          'lHip': Offset(cx, cy - 40),
          'rKnee': Offset(cx, cy + 40),
          'lKnee': Offset(cx, cy + 40),
          'rAnkle': Offset(cx, cy + 130),
          'lAnkle': Offset(cx, cy + 130),
        };
        break;

      case 'El Camello':
        points = {
          'head': Offset(cx - (60 * sideMult), cy - 100),
          'neck': Offset(cx - (40 * sideMult), cy - 70),
          'rShoulder': Offset(cx - (30 * sideMult), cy - 50),
          'lShoulder': Offset(cx - (30 * sideMult), cy - 50),
          'rElbow': Offset(cx + (10 * sideMult), cy - 20),
          'lElbow': Offset(cx + (10 * sideMult), cy - 20),
          'rWrist': Offset(cx + (40 * sideMult), cy + 30),
          'lWrist': Offset(cx + (40 * sideMult), cy + 30),
          'rHip': Offset(cx - (10 * sideMult), cy + 10),
          'lHip': Offset(cx - (10 * sideMult), cy + 10),
          'rKnee': Offset(cx - (10 * sideMult), cy + 90),
          'lKnee': Offset(cx - (10 * sideMult), cy + 90),
          'rAnkle': Offset(cx + (40 * sideMult), cy + 90),
          'lAnkle': Offset(cx + (40 * sideMult), cy + 90),
        };
        break;

      case 'Señor de los Peces':
        points = {
          'head': Offset(cx, cy - 100),
          'neck': Offset(cx, cy - 60),
          'rShoulder': Offset(cx - 30, cy - 40),
          'lShoulder': Offset(cx + 30, cy - 40),
          'rElbow': Offset(cx - 50, cy + 10),
          'lElbow': Offset(cx + 10, cy),
          'rWrist': Offset(cx - 20, cy + 60),
          'lWrist': Offset(cx + 20, cy + 50),
          'rHip': Offset(cx - 20, cy + 50),
          'lHip': Offset(cx + 20, cy + 50),
          'rKnee': Offset(cx - (60 * sideMult), cy + 30),
          'lKnee': Offset(cx + (40 * sideMult), cy + 80),
          'rAnkle': Offset(cx + (20 * sideMult), cy + 80),
          'lAnkle': Offset(cx - (40 * sideMult), cy + 80),
        };
        break;

      case 'La Paloma':
        points = {
          'head': Offset(cx - (60 * sideMult), cy - 60),
          'neck': Offset(cx - (40 * sideMult), cy - 20),
          'rShoulder': Offset(cx - (30 * sideMult), cy),
          'lShoulder': Offset(cx - (30 * sideMult), cy),
          'rElbow': Offset(cx - (30 * sideMult), cy + 40),
          'lElbow': Offset(cx - (30 * sideMult), cy + 40),
          'rWrist': Offset(cx - (30 * sideMult), cy + 70),
          'lWrist': Offset(cx - (30 * sideMult), cy + 70),
          'rHip': Offset(cx, cy + 40),
          'lHip': Offset(cx, cy + 40),
          'rKnee': Offset(cx - (60 * sideMult), cy + 60),
          'lKnee': Offset(cx + (80 * sideMult), cy + 50),
          'rAnkle': Offset(cx, cy + 70),
          'lAnkle': Offset(cx + (150 * sideMult), cy + 50),
        };
        break;

      case 'La Mariposa':
        points = {
          'head': Offset(cx, cy - 100),
          'neck': Offset(cx, cy - 60),
          'rShoulder': Offset(cx - 30, cy - 40),
          'lShoulder': Offset(cx + 30, cy - 40),
          'rElbow': Offset(cx - 40, cy + 10),
          'lElbow': Offset(cx + 40, cy + 10),
          'rWrist': Offset(cx - 10, cy + 60),
          'lWrist': Offset(cx + 10, cy + 60),
          'rHip': Offset(cx - 20, cy + 40),
          'lHip': Offset(cx + 20, cy + 40),
          'rKnee': Offset(cx - 80, cy + 60),
          'lKnee': Offset(cx + 80, cy + 60),
          'rAnkle': Offset(cx, cy + 70),
          'lAnkle': Offset(cx, cy + 70),
        };
        break;

      case 'El Barco':
        points = {
          'head': Offset(cx - (80 * sideMult), cy - 80),
          'neck': Offset(cx - (60 * sideMult), cy - 50),
          'rShoulder': Offset(cx - (50 * sideMult), cy - 30),
          'lShoulder': Offset(cx - (50 * sideMult), cy - 30),
          'rElbow': Offset(cx - (10 * sideMult), cy - 10),
          'lElbow': Offset(cx - (10 * sideMult), cy - 10),
          'rWrist': Offset(cx + (30 * sideMult), cy + 10),
          'lWrist': Offset(cx + (30 * sideMult), cy + 10),
          'rHip': Offset(cx - (20 * sideMult), cy + 50),
          'lHip': Offset(cx - (20 * sideMult), cy + 50),
          'rKnee': Offset(cx + (40 * sideMult), cy - 10),
          'lKnee': Offset(cx + (40 * sideMult), cy - 10),
          'rAnkle': Offset(cx + (100 * sideMult), cy - 70),
          'lAnkle': Offset(cx + (100 * sideMult), cy - 70),
        };
        break;

      default:
        points = {
          'head': Offset(cx, cy - 160),
          'neck': Offset(cx, cy - 120),
          'rShoulder': Offset(cx - 30, cy - 110),
          'lShoulder': Offset(cx + 30, cy - 110),
          'rElbow': Offset(cx - 35, cy - 50),
          'lElbow': Offset(cx + 35, cy - 50),
          'rWrist': Offset(cx - 40, cy + 10),
          'lWrist': Offset(cx + 40, cy + 10),
          'rHip': Offset(cx - 20, cy + 10),
          'lHip': Offset(cx + 20, cy + 10),
          'rKnee': Offset(cx - 20, cy + 90),
          'lKnee': Offset(cx + 20, cy + 90),
          'rAnkle': Offset(cx - 20, cy + 170),
          'lAnkle': Offset(cx + 20, cy + 170),
        };
        break;
    }

    void drawLine(String p1, String p2) {
      if (points.containsKey(p1) && points.containsKey(p2)) {
        canvas.drawLine(points[p1]!, points[p2]!, paint);
      }
    }

    drawLine('head', 'neck');
    drawLine('neck', 'rShoulder');
    drawLine('neck', 'lShoulder');
    drawLine('rShoulder', 'rElbow');
    drawLine('rElbow', 'rWrist');
    drawLine('lShoulder', 'lElbow');
    drawLine('lElbow', 'lWrist');
    drawLine('rShoulder', 'rHip');
    drawLine('lShoulder', 'lHip');
    drawLine('rHip', 'lHip');
    drawLine('rHip', 'rKnee');
    drawLine('rKnee', 'rAnkle');
    drawLine('lHip', 'lKnee');
    drawLine('lKnee', 'lAnkle');

    points.forEach((key, point) {
      canvas.drawCircle(point, key == 'head' ? 14 : 6, jointPaint);
    });
  }

  @override
  bool shouldRepaint(covariant PoseGuidePainter oldDelegate) {
    return oldDelegate.asanaName != asanaName ||
        oldDelegate.isAligned != isAligned ||
        oldDelegate.isRightSide != isRightSide;
  }
}