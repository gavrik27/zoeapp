import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'homePage.dart';

class FocusSessionPage extends StatefulWidget {
  const FocusSessionPage({super.key});

  @override
  State<FocusSessionPage> createState() => _FocusSessionPageState();
}

class _FocusSessionPageState extends State<FocusSessionPage> {
   static const platform = MethodChannel('app.intozon.zon/kiosk');
  late VideoPlayerController _videoController;

  // Control de flujo entre Pantalla F1 y F2
  bool _isBeforeYouGo = false; 

  // Estado del temporizador principal (F1 - Contador ascendente o descendente simulado)
  Timer? _focusTimer;
  int _focusSeconds = 1490; // 24:50 inicial de la imagen
  bool _isTimerRunning = true;

  // Estado del temporizador de escape (F2 - Countdown de 15 segundos)
  Timer? _countdownTimer;
  int _escapeCountdown = 15;

  @override
  void initState() {
    super.initState();
     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
    ));
    // Inicialización del video de fondo (Amanecer / Selva Amazónica)
    _videoController = VideoPlayerController.asset('assets/assets-s13-live.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
        setState(() {});
      });

    _startFocusTimer();
  }
  Future<void> _desactivarYSalir() async {
    try {
      // Apagamos el bloqueo nativo
      await platform.invokeMethod('setKioskActive', {'active': false});
      // Restauramos las barras normales de Android
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      print(e);
    }

    // Cerramos o redirigimos de forma segura
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }


  @override
  void dispose() {
    _videoController.dispose();
    _focusTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Lógica del contador principal de enfoque (F1)
  void _startFocusTimer() {
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning) {
        setState(() {
          // Cambiar a desensolar si es un cronómetro inverso, o ++ si es ascendente
          _focusSeconds--; 
        });
      }
    });
  }

  // Lógica del contador regresivo de retención de 15 segundos (F2)
  void _startEscapeCountdown() {
    _escapeCountdown = 15;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_escapeCountdown > 1) {
        setState(() {
          _escapeCountdown--;
        });
      } else {
        _countdownTimer?.cancel();
        _onSessionTimeoutAction(); // Acción al llegar a 0 segundos
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- NAVEGACIONES Y ACCIONES ---
  
  void _onSessionTimeoutAction() {
    // Función ejecutada si el contador de 15 segundos llega a 0
    Navigator.of(context).pop(); 
  }

  void _onEndSessionAction() {
    // Función ejecutada si pulsa explícitamente "End session"
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- CAPA 1: VIDEO DE FONDO ---
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      // Se oscurece más la pantalla en el modo F2 ("Before you go") para centrar la vista en el círculo
                      Colors.black.withOpacity(_isBeforeYouGo ? 0.65 : 0.4), 
                      BlendMode.darken,
                    ),
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: _videoController.value.size.width,
                          height: _videoController.value.size.height,
                          child: VideoPlayer(_videoController),
                        ),
                      ),
                    ),
                  )
                : Container(color: Colors.black),
          ),

          // --- CAPA 2: INTERFAZ DINÁMICA (F1 o F2) ---
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isBeforeYouGo ? _buildBeforeYouGoScreen() : _buildActiveFocusScreen(),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // INTERFAZ F1: FOCUSING SCREEN
  // =========================================================================
  Widget _buildActiveFocusScreen() {
    return Padding(
      key: const ValueKey('ActiveFocusScreen'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Barra de herramientas superior (Cerrar de forma temporal, audio)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircularTopButton(Icons.close, onTap: () {
                setState(() {
                  _isBeforeYouGo = true;
                  _startEscapeCountdown();
                });
              }),
              _buildCircularTopButton(Icons.volume_up_outlined, onTap: () {
                // Alternar silencio de ambiente
              }),
            ],
          ),

          // Cronómetro Central Glaseado
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FOCUSING',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                  color: Colors.white.withOpacity(0.02),
                ),
                child: Center(
                  child: Text(
                    _formatDuration(_focusSeconds),
                    style: const TextStyle(
                      fontFamily: 'Sans', 
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Leyenda inferior
          Text(
            'Your habitat, quietly with you.',
            style: TextStyle(
              fontFamily: 'Serif',
              fontStyle: FontStyle.italic,
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
            ),
          ),

          // Controles de acción inferiores (Pause / End)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón PAUSE / PLAY
                _buildBottomControl(
                  label: _isTimerRunning ? 'PAUSE' : 'PLAY',
                  icon: _isTimerRunning ? Icons.pause : Icons.play_arrow,
                  onTap: () {
                    setState(() {
                      _isTimerRunning = !_isTimerRunning;
                    });
                  },
                ),
                const SizedBox(width: 40),
                // Botón END
                _buildBottomControl(
                  label: 'END',
                  icon: Icons.stop,
                  onTap: () {
                    setState(() {
                      _isBeforeYouGo = true;
                      _startEscapeCountdown(); // Activa la cuenta regresiva de 15s de F2
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // INTERFAZ F2: BEFORE YOU GO SCREEN
  // =========================================================================
  Widget _buildBeforeYouGoScreen() {
    return Padding(
      key: const ValueKey('BeforeYouGoScreen'),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          
          Text(
            'BEFORE YOU GO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
          
          const SizedBox(height: 35),

          // Círculo de Respiración Consciente central
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.02),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ]
              ),
              child: Center(
                child: Text(
                  'Breathe in',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Contador regresivo de 15 segundos
          Text(
            '0:${_escapeCountdown.toString().padLeft(2, '0')}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Breathe. Make sure you really want to\nend this session early.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w300,
            ),
          ),

          const Spacer(),

          // Botón Primario: Cancelar escape y volver a la sesión (F1)
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              color: Colors.white.withOpacity(0.08),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: () {
                  _countdownTimer?.cancel();
                  setState(() {
                    _isBeforeYouGo = false; // Regresa fluidamente a F1
                    _isTimerRunning = true; 
                  });
                },
                child: const Center(
                  child: Text(
                    'Keep focusing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botón Secundario: Forzar el cierre inmediato de la sesión
          GestureDetector(
            onTap: () {
              _countdownTimer?.cancel();
              _desactivarYSalir();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.transparent,
              child: const Text(
                'End session',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // =========================================================================
  // SUB-WIDGETS REUTILIZABLES DE CONSTRUCCIÓN
  // =========================================================================

  Widget _buildCircularTopButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
      ),
    );
  }

  Widget _buildBottomControl({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}