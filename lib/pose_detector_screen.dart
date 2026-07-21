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
  final Map<String, List<String>> _asanaSteps = {
    "La Montaña": [
      "Pies al ancho de caderas.",
      "Distribuye el peso.",
      "Alarga la columna.",
    ],
    "Perro Boca Abajo": [
      "Manos firmes al ancho de hombros.",
      "Eleva la cadera.",
      "Empuja el suelo.",
    ],
    "El Guerrero II": [
      "Piernas separadas.",
      "Dobla rodilla delantera.",
      "Brazos en cruz.",
    ],
  };

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
    final activeHip = _isRightSide
        ? pose.landmarks[PoseLandmarkType.rightHip]
        : pose.landmarks[PoseLandmarkType.leftHip];
    final activeKnee = _isRightSide
        ? pose.landmarks[PoseLandmarkType.rightKnee]
        : pose.landmarks[PoseLandmarkType.leftKnee];
    final activeAnkle = _isRightSide
        ? pose.landmarks[PoseLandmarkType.rightAnkle]
        : pose.landmarks[PoseLandmarkType.leftAnkle];

    final oppositeHip = _isRightSide
        ? pose.landmarks[PoseLandmarkType.leftHip]
        : pose.landmarks[PoseLandmarkType.rightHip];
    final oppositeKnee = _isRightSide
        ? pose.landmarks[PoseLandmarkType.leftKnee]
        : pose.landmarks[PoseLandmarkType.rightKnee];
    final oppositeAnkle = _isRightSide
        ? pose.landmarks[PoseLandmarkType.leftAnkle]
        : pose.landmarks[PoseLandmarkType.rightAnkle];

    final activeShoulder = _isRightSide
        ? pose.landmarks[PoseLandmarkType.rightShoulder]
        : pose.landmarks[PoseLandmarkType.leftShoulder];
    final activeElbow = _isRightSide
        ? pose.landmarks[PoseLandmarkType.rightElbow]
        : pose.landmarks[PoseLandmarkType.leftElbow];

    if (activeHip == null ||
        activeKnee == null ||
        activeAnkle == null ||
        oppositeHip == null ||
        oppositeKnee == null ||
        oppositeAnkle == null) {
      setState(() {
        _feedbackMessage = "Cuerpo incompleto en cámara. Da un paso atrás.";
        _isAlignmentCorrect = false;
      });
      return;
    }

    // 1. EL ÁRBOL
    if (widget.asanaName == 'El Árbol') {
      if (activeShoulder != null && activeShoulder.y > activeHip.y) {
        setState(() {
          _feedbackMessage = "¡Ponte de pie! Estás inclinado o boca abajo.";
          _isAlignmentCorrect = false;
        });
        return;
      }

      double kneeAngle = _calculateAngle(activeHip, activeKnee, activeAnkle);
      bool isKneeBent = kneeAngle >= 60 && kneeAngle <= 125;

      if (isKneeBent) {
        _handleAlignment(
          correct: true,
          message: "¡Ángulo de pierna óptimo! Mantén el equilibrio.",
          speech: "Excelente postura. Quédate ahí.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Corrección: Dobla más la rodilla y apoya el pie en el muslo contrario.",
          speech: "Alineación incorrecta. Sube más tu pie.",
        );
      }
    }
    // 2. EL GUERRERO II
    else if (widget.asanaName == 'El Guerrero' ||
        widget.asanaName == 'El Guerrero II') {
      if (activeShoulder != null &&
          (activeShoulder.y > activeHip.y || activeHip.y > activeAnkle.y)) {
        setState(() {
          _feedbackMessage =
              "Asegúrate de estar de pie para la postura del Guerrero.";
          _isAlignmentCorrect = false;
        });
        return;
      }

      double frontKneeAngle = _calculateAngle(
        activeHip,
        activeKnee,
        activeAnkle,
      );
      double backKneeAngle = _calculateAngle(
        oppositeHip,
        oppositeKnee,
        oppositeAnkle,
      );

      bool isFrontKneeCorrect = frontKneeAngle >= 75 && frontKneeAngle <= 120;
      bool isBackLegStraight = backKneeAngle >= 145 && backKneeAngle <= 180;

      if (isFrontKneeCorrect && isBackLegStraight) {
        _handleAlignment(
          correct: true,
          message:
              "¡Perfecto! Rodilla delantera doblada y pierna trasera estirada.",
          speech: "Guerrero perfecto. Mantén la fuerza.",
        );
      } else if (!isFrontKneeCorrect) {
        _handleAlignment(
          correct: false,
          message:
              "Corrección: Flexiona tu rodilla delantera a unos 90 grados.",
          speech: "Baja más tu cadera y dobla la rodilla de delante.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Corrección: Estira completamente la pierna que tienes detrás.",
          speech: "Estira la pierna de atrás.",
        );
      }
    }
    // 3. LA PLANCHA
    else if (widget.asanaName == 'La Plancha') {
      if (activeShoulder == null) {
        setState(() {
          _feedbackMessage =
              "Ponte completamente de perfil para evaluar la plancha.";
          _isAlignmentCorrect = false;
        });
        return;
      }

      double heightDifference = (activeShoulder.y - activeAnkle.y).abs();
      double widthDifference = (activeShoulder.x - activeAnkle.x).abs();

      if (widthDifference < heightDifference) {
        setState(() {
          _feedbackMessage =
              "Túmbate en el suelo de perfil para hacer la plancha.";
          _isAlignmentCorrect = false;
        });
        return;
      }

      double bodyAlignmentAngle = _calculateAngle(
        activeShoulder,
        activeHip,
        activeAnkle,
      );
      bool isPlankStraight =
          bodyAlignmentAngle >= 155 && bodyAlignmentAngle <= 180;

      if (isPlankStraight) {
        _handleAlignment(
          correct: true,
          message: "¡Plancha perfecta! Abdomen fuerte y cuerpo alineado.",
          speech: "Muy bien alineado. Aprieta el abdomen.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Corrección: Alinea tu espalda. No subas ni bajes de más la cadera.",
          speech:
              "Mantén el cuerpo en línea recta. Corrige la altura de la cadera.",
        );
      }
    }
    // 4. EL TRIÁNGULO
    else if (widget.asanaName == 'El Triángulo') {
      if (activeShoulder == null) return;
      double hipAngle = _calculateAngle(activeShoulder, activeHip, activeAnkle);
      bool isSideBendCorrect = hipAngle >= 110 && hipAngle <= 150;

      if (isSideBendCorrect) {
        _handleAlignment(
          correct: true,
          message: "¡Excelente inclinación lateral! Mantiene el pecho abierto.",
          speech: "Triángulo muy bien ejecutado. Sostén la postura.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Inclínate lateralmente buscando alcanzar el tobillo con tu mano.",
          speech: "Baja un poco más lateralmente sin doblar las rodillas.",
        );
      }
    }
    // 5. LA COBRA
    else if (widget.asanaName == 'La Cobra') {
      if (activeShoulder == null) return;
      double backAngle = _calculateAngle(
        activeShoulder,
        activeHip,
        activeAnkle,
      );
      bool isCobraCurve = backAngle >= 120 && backAngle <= 160;

      if (isCobraCurve) {
        _handleAlignment(
          correct: true,
          message: "¡Apertura de pecho perfecta! Hombros lejos de las orejas.",
          speech: "Excelente cobra. Inhala profundo.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Eleva el torso apoyando las palmas en el suelo y arquea la espalda.",
          speech: "Empuja el suelo y eleva el pecho.",
        );
      }
    }
    // 6. LA SILLA
    else if (widget.asanaName == 'La Silla') {
      double activeKneeAngle = _calculateAngle(
        activeHip,
        activeKnee,
        activeAnkle,
      );
      bool isSquatCorrect = activeKneeAngle >= 80 && activeKneeAngle <= 125;

      if (isSquatCorrect) {
        _handleAlignment(
          correct: true,
          message:
              "¡Postura de la Silla firme! Brazos hacia arriba y cadera abajo.",
          speech: "Gran fuerza en piernas. Sostén la Silla.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message: "Baja la cadera como si te fueras a sentar en una silla.",
          speech: "Flexiona más las rodillas y baja la cadera.",
        );
      }
    }
    // 7. PERRO BOCA ABAJO
    else if (widget.asanaName == 'Perro Boca Abajo') {
      if (activeShoulder == null) return;
      double invertedV = _calculateAngle(
        activeShoulder,
        activeHip,
        activeAnkle,
      );
      bool isVInverted = invertedV >= 60 && invertedV <= 100;

      if (isVInverted) {
        _handleAlignment(
          correct: true,
          message: "¡V invertida perfecta! Empuja el suelo con las manos.",
          speech: "Excelente Perro Boca Abajo. Alarga tu columna.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Sube la cadera hacia el techo formando una V invertida con tu cuerpo.",
          speech: "Eleva la cadera hacia arriba y atrás.",
        );
      }
    }
    // 8. EL GUERRERO I
    else if (widget.asanaName == 'El Guerrero I') {
      if (activeShoulder == null || activeElbow == null) return;
      double kneeAngle = _calculateAngle(activeHip, activeKnee, activeAnkle);
      bool isFrontBent = kneeAngle >= 75 && kneeAngle <= 120;
      bool armsUp = activeElbow.y < activeShoulder.y;

      if (isFrontBent && armsUp) {
        _handleAlignment(
          correct: true,
          message: "¡Guerrero I sólido! Cadera al frente y brazos elevados.",
          speech: "Perfecto Guerrero I. Siente el poder.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Dobla la rodilla delantera y eleva ambos brazos hacia el cielo.",
          speech: "Eleva los brazos y flexiona la pierna de adelante.",
        );
      }
    }
    // 9. LA MEDIA LUNA
    else if (widget.asanaName == 'La Media Luna') {
      double standingLeg = _calculateAngle(activeHip, activeKnee, activeAnkle);
      double balanceAngle = _calculateAngle(
        oppositeHip,
        activeHip,
        activeAnkle,
      );

      bool isLegStraight = standingLeg >= 150 && standingLeg <= 180;
      bool isFloatingLegUp = balanceAngle >= 75 && balanceAngle <= 125;

      if (isLegStraight && isFloatingLegUp) {
        _handleAlignment(
          correct: true,
          message:
              "¡Increíble equilibrio en Media Luna! Pecho y cadera abiertos.",
          speech: "Equilibrio magistral. Quédate ahí.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Apoya una mano en el suelo y eleva la pierna trasera en el aire.",
          speech: "Eleva más la pierna de atrás y abre la cadera.",
        );
      }
    }
    // 10. EL PUENTE
    else if (widget.asanaName == 'El Puente') {
      double hipBridge = _calculateAngle(
        activeShoulder ?? activeHip,
        activeHip,
        activeKnee,
      );
      bool isBridgeUp = hipBridge >= 140 && hipBridge <= 180;

      if (isBridgeUp) {
        _handleAlignment(
          correct: true,
          message: "¡Puente bien elevado! Glúteos e isquiotibiales activos.",
          speech: "Puente excelente. Respira con el abdomen.",
        );
      } else {
        _handleAlignment(
          correct: false,
          message:
              "Túmbate boca arriba y empuja la cadera alto hacia el techo.",
          speech: "Eleva más la cadera despegando los glúteos del suelo.",
        );
      }
    } else {
      _handleAlignment(
        correct: false,
        message: "Preparando postura: Colócate frente a la cámara...",
        speech: "",
      );
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
              _speak(
                "Excelente. Sesión completada con éxito en ambos lados.",
                force: true,
              );
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

    // --- AÑADE ESTA LÍNEA PARA GUARDAR EL PROGRESO EN LA ACADEMIA ---
    // (Asegúrate de pasar el identificador correcto de la lección o la asana)
    await AcademyProgressService.completeLesson(widget.asanaName); 

    if (widget.onPoseCompleted != null) {
      widget.onPoseCompleted!(60);
    } else {
      Future.delayed(const Duration(milliseconds: 3000), () {
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

  Widget _buildTimerWidget() {
    double progress = _secondsRemaining / _poseDuration.toDouble();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
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
          width: 115,
          height: 115,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _isCompleted
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 55,
                  )
                : Text(
                    "$_secondsRemaining",
                    style: TextStyle(
                      fontSize: 42,
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

  @override
  Widget build(BuildContext context) {
    final steps = _asanaSteps[widget.asanaName] ?? ["Mantén la postura"];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          
          Container(color: Colors.black.withValues(alpha: 0.2)),

          // 1. Overlay de Instrucción Profesional
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "Paso ${_currentStep + 1} / ${steps.length}:",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    steps[_currentStep],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // 2. Botón de Control de Pasos (NUEVO)
          Positioned(
            bottom: 280,
            left: 40,
            right: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_currentStep < steps.length - 1) {
                    _currentStep++;
                  } else {
                    _speak("Pasos completados. Inicia la retención.");
                  }
                });
              },
              child: Text(
                _currentStep < steps.length - 1 ? "Siguiente Paso" : "Modo Práctica Activo",
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
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.asanaName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Text(
                    "LADO: ${_isRightSide ? 'DERECHO' : 'IZQUIERDO'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ),

                _buildTimerWidget(),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isAlignmentCorrect
                          ? const Color(0xFF4A7C59).withValues(alpha: 0.85)
                          : Colors.orangeAccent.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isAlignmentCorrect ? const Color(0xFF8FF0A3) : Colors.orangeAccent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isAlignmentCorrect ? Icons.gpp_good_rounded : Icons.info_outline_rounded,
                              color: _isAlignmentCorrect ? const Color(0xFF8FF0A3) : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCompleted
                                  ? "¡COMPLETADO!"
                                  : _isAlignmentCorrect
                                      ? "ALINEACIÓN CORRECTA"
                                      : "ALINEA TU LADO ${_isRightSide ? 'DERECHO' : 'IZQUIERDO'}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _feedbackMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isPermissionGranted ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Container(
        color: const Color(0xFF2D3A3A),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                color: Colors.white38,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                "Iniciando cámara de SpainToBali...",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.previewSize!.height,
        height: _controller!.value.previewSize!.width,
        child: CameraPreview(_controller!),
      ),
    );
  }
}

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
          ? Colors.green.withValues(alpha: 0.55)
          : Colors.orangeAccent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final joinPaint = Paint()
      ..color = isAligned
          ? Colors.greenAccent
          : Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final double directionMultiplier = isRightSide ? 1.0 : -1.0;

    if (asanaName == 'El Árbol') {
      final head = Offset(cx, cy - 140);
      final neck = Offset(cx, cy - 90);
      final leftShoulder = Offset(cx - (45 * directionMultiplier), cy - 80);
      final rightShoulder = Offset(cx + (45 * directionMultiplier), cy - 80);
      final leftElbow = Offset(cx - (30 * directionMultiplier), cy - 160);
      final leftWrist = Offset(cx - (10 * directionMultiplier), cy - 210);
      final rightElbow = Offset(cx + (30 * directionMultiplier), cy - 160);
      final rightWrist = Offset(cx + (10 * directionMultiplier), cy - 210);
      final spineLow = Offset(cx, cy + 20);
      final leftHip = Offset(cx - (30 * directionMultiplier), cy + 30);
      final rightHip = Offset(cx + (30 * directionMultiplier), cy + 30);
      final supportKnee = Offset(cx + (30 * directionMultiplier), cy + 110);
      final supportAnkle = Offset(cx + (30 * directionMultiplier), cy + 190);
      final activeKnee = Offset(cx - (75 * directionMultiplier), cy + 80);
      final activeAnkle = Offset(cx + (15 * directionMultiplier), cy + 100);

      canvas.drawLine(leftShoulder, rightShoulder, paint);
      canvas.drawLine(neck, spineLow, paint);
      canvas.drawLine(leftHip, rightHip, paint);
      canvas.drawLine(leftShoulder, leftElbow, paint);
      canvas.drawLine(leftElbow, leftWrist, paint);
      canvas.drawLine(rightShoulder, rightElbow, paint);
      canvas.drawLine(rightElbow, rightWrist, paint);
      canvas.drawLine(rightHip, supportKnee, paint);
      canvas.drawLine(supportKnee, supportAnkle, paint);
      canvas.drawLine(leftHip, activeKnee, paint);
      canvas.drawLine(activeKnee, activeAnkle, paint);

      final points = [head, neck, leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist, leftHip, rightHip, supportKnee, supportAnkle, activeKnee, activeAnkle];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 25.0, paint);
    } else if (asanaName == 'El Guerrero' || asanaName == 'El Guerrero II') {
      final head = Offset(cx - (20 * directionMultiplier), cy - 110);
      final neck = Offset(cx - (20 * directionMultiplier), cy - 70);
      final leftShoulder = Offset(cx - (60 * directionMultiplier), cy - 60);
      final rightShoulder = Offset(cx + (20 * directionMultiplier), cy - 60);
      final leftElbow = Offset(cx - (110 * directionMultiplier), cy - 60);
      final leftWrist = Offset(cx - (150 * directionMultiplier), cy - 60);
      final rightElbow = Offset(cx + (70 * directionMultiplier), cy - 60);
      final rightWrist = Offset(cx + (110 * directionMultiplier), cy - 60);
      final spineLow = Offset(cx - (10 * directionMultiplier), cy + 30);
      final leftHip = Offset(cx - (40 * directionMultiplier), cy + 40);
      final rightHip = Offset(cx + (20 * directionMultiplier), cy + 40);
      final frontKnee = Offset(cx - (90 * directionMultiplier), cy + 80);
      final frontAnkle = Offset(cx - (90 * directionMultiplier), cy + 150);
      final backKnee = Offset(cx + (60 * directionMultiplier), cy + 100);
      final backAnkle = Offset(cx + (100 * directionMultiplier), cy + 150);

      canvas.drawLine(leftShoulder, rightShoulder, paint);
      canvas.drawLine(neck, spineLow, paint);
      canvas.drawLine(leftHip, rightHip, paint);
      canvas.drawLine(leftShoulder, leftElbow, paint);
      canvas.drawLine(leftElbow, leftWrist, paint);
      canvas.drawLine(rightShoulder, rightElbow, paint);
      canvas.drawLine(rightElbow, rightWrist, paint);
      canvas.drawLine(leftHip, frontKnee, paint);
      canvas.drawLine(frontKnee, frontAnkle, paint);
      canvas.drawLine(rightHip, backKnee, paint);
      canvas.drawLine(backKnee, backAnkle, paint);

      final points = [head, neck, leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist, leftHip, rightHip, frontKnee, frontAnkle, backKnee, backAnkle];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 24.0, paint);
    } else if (asanaName == 'La Plancha') {
      final head = Offset(cx - (120 * directionMultiplier), cy + 10);
      final neck = Offset(cx - (90 * directionMultiplier), cy + 20);
      final leftShoulder = Offset(cx - (70 * directionMultiplier), cy + 30);
      final leftHip = Offset(cx, cy + 45);
      final leftKnee = Offset(cx + (60 * directionMultiplier), cy + 55);
      final leftAnkle = Offset(cx + (120 * directionMultiplier), cy + 65);
      final leftElbow = Offset(cx - (70 * directionMultiplier), cy + 80);
      final leftWrist = Offset(cx - (70 * directionMultiplier), cy + 120);

      canvas.drawLine(neck, leftHip, paint);
      canvas.drawLine(leftHip, leftKnee, paint);
      canvas.drawLine(leftKnee, leftAnkle, paint);
      canvas.drawLine(leftShoulder, leftElbow, paint);
      canvas.drawLine(leftElbow, leftWrist, paint);

      final points = [head, neck, leftShoulder, leftHip, leftKnee, leftAnkle, leftElbow, leftWrist];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 22.0, paint);
    } else if (asanaName == 'El Triángulo') {
      final head = Offset(cx - (60 * directionMultiplier), cy - 20);
      final shoulder = Offset(cx - (40 * directionMultiplier), cy);
      final hip = Offset(cx, cy + 30);
      final ankleFront = Offset(cx - (50 * directionMultiplier), cy + 150);
      final ankleBack = Offset(cx + (50 * directionMultiplier), cy + 150);
      final armDown = Offset(cx - (50 * directionMultiplier), cy + 120);
      final armUp = Offset(cx - (20 * directionMultiplier), cy - 100);

      canvas.drawLine(shoulder, hip, paint);
      canvas.drawLine(hip, ankleFront, paint);
      canvas.drawLine(hip, ankleBack, paint);
      canvas.drawLine(shoulder, armDown, paint);
      canvas.drawLine(shoulder, armUp, paint);

      final points = [head, shoulder, hip, ankleFront, ankleBack, armDown, armUp];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 22.0, paint);
    } else if (asanaName == 'La Cobra') {
      final head = Offset(cx - (80 * directionMultiplier), cy - 60);
      final shoulder = Offset(cx - (50 * directionMultiplier), cy - 20);
      final hip = Offset(cx + 20, cy + 40);
      final ankle = Offset(cx + (120 * directionMultiplier), cy + 50);
      final wrist = Offset(cx - (50 * directionMultiplier), cy + 40);

      canvas.drawLine(shoulder, hip, paint);
      canvas.drawLine(hip, ankle, paint);
      canvas.drawLine(shoulder, wrist, paint);

      final points = [head, shoulder, hip, ankle, wrist];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 22.0, paint);
    } else if (asanaName == 'La Silla') {
      final head = Offset(cx, cy - 120);
      final shoulder = Offset(cx, cy - 80);
      final hip = Offset(cx - (30 * directionMultiplier), cy + 10);
      final knee = Offset(cx + (30 * directionMultiplier), cy + 60);
      final ankle = Offset(cx + (10 * directionMultiplier), cy + 140);
      final wrist = Offset(cx + (40 * directionMultiplier), cy - 140);

      canvas.drawLine(shoulder, hip, paint);
      canvas.drawLine(hip, knee, paint);
      canvas.drawLine(knee, ankle, paint);
      canvas.drawLine(shoulder, wrist, paint);

      final points = [head, shoulder, hip, knee, ankle, wrist];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 22.0, paint);
    } else if (asanaName == 'Perro Boca Abajo') {
      final hip = Offset(cx, cy - 80);
      final shoulder = Offset(cx - (70 * directionMultiplier), cy + 40);
      final wrist = Offset(cx - (100 * directionMultiplier), cy + 120);
      final ankle = Offset(cx + (80 * directionMultiplier), cy + 120);
      final head = Offset(cx - (80 * directionMultiplier), cy + 60);

      canvas.drawLine(hip, shoulder, paint);
      canvas.drawLine(shoulder, wrist, paint);
      canvas.drawLine(hip, ankle, paint);

      final points = [head, hip, shoulder, wrist, ankle];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 20.0, paint);
    } else if (asanaName == 'El Guerrero I') {
      final head = Offset(cx, cy - 130);
      final shoulder = Offset(cx, cy - 80);
      final wrist = Offset(cx, cy - 180);
      final hip = Offset(cx, cy + 20);
      final kneeFront = Offset(cx - (50 * directionMultiplier), cy + 70);
      final ankleFront = Offset(cx - (50 * directionMultiplier), cy + 140);
      final ankleBack = Offset(cx + (70 * directionMultiplier), cy + 140);

      canvas.drawLine(shoulder, wrist, paint);
      canvas.drawLine(shoulder, hip, paint);
      canvas.drawLine(hip, kneeFront, paint);
      canvas.drawLine(kneeFront, ankleFront, paint);
      canvas.drawLine(hip, ankleBack, paint);

      final points = [head, shoulder, wrist, hip, kneeFront, ankleFront, ankleBack];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 22.0, paint);
    } else if (asanaName == 'La Media Luna') {
      final hip = Offset(cx, cy);
      final shoulder = Offset(cx - (50 * directionMultiplier), cy);
      final wristDown = Offset(cx - (50 * directionMultiplier), cy + 90);
      final wristUp = Offset(cx - (50 * directionMultiplier), cy - 90);
      final ankleStanding = Offset(cx, cy + 120);
      final ankleFloating = Offset(cx + (90 * directionMultiplier), cy);
      final head = Offset(cx - (80 * directionMultiplier), cy);

      canvas.drawLine(shoulder, hip, paint);
      canvas.drawLine(shoulder, wristDown, paint);
      canvas.drawLine(shoulder, wristUp, paint);
      canvas.drawLine(hip, ankleStanding, paint);
      canvas.drawLine(hip, ankleFloating, paint);

      final points = [head, shoulder, hip, wristDown, wristUp, ankleStanding, ankleFloating];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 20.0, paint);
    } else if (asanaName == 'El Puente') {
      final head = Offset(cx - (100 * directionMultiplier), cy + 60);
      final shoulder = Offset(cx - (70 * directionMultiplier), cy + 60);
      final hip = Offset(cx, cy - 10);
      final knee = Offset(cx + (60 * directionMultiplier), cy + 20);
      final ankle = Offset(cx + (60 * directionMultiplier), cy + 80);

      canvas.drawLine(shoulder, hip, paint);
      canvas.drawLine(hip, knee, paint);
      canvas.drawLine(knee, ankle, paint);

      final points = [head, shoulder, hip, knee, ankle];
      for (var point in points) {
        canvas.drawCircle(point, 7.0, joinPaint);
      }
      canvas.drawCircle(head, 22.0, paint);
    } else {
      final head = Offset(cx, cy - 120);
      final neck = Offset(cx, cy - 80);
      final spineLow = Offset(cx, cy + 40);
      canvas.drawLine(neck, spineLow, paint);
      canvas.drawCircle(head, 22.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PoseGuidePainter oldDelegate) {
    return oldDelegate.asanaName != asanaName ||
        oldDelegate.isAligned != isAligned ||
        oldDelegate.isRightSide != isRightSide;
  }
}