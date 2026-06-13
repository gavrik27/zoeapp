import 'dart:ui';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import 'homePage.dart';
// --- PALETA DE COLORES ZŌN ---
class ZonColors {
  static const Color obsidian = Color(0xFF06141E);
  static const Color obsidianBg = Color(0xFF0A0A0C);
  static const Color bone = Color(0xFFF2EDE0);
  static const Color gold = Color(0xFFF2A938);
  static const Color flare = Color(0xFFFF5A4D);
  static Color bone60 = const Color(0xFFF2EDE0).withOpacity(0.60);
  static Color bone40 = const Color(0xFFF2EDE0).withOpacity(0.40);
  static Color GlassBg = const Color(0xFF1A1A1E).withOpacity(0.4);
  static Color GlassBorder = const Color(0xFFFFFFFF).withOpacity(0.15);
  static Color colorVerdeEsmeralda = Color(0xFF2ECC71);
} 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Filtro Anti-Spam para logs de la GPU al reproducir video o ruidos nativos
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && (message.contains('gralloc4') || message.contains('BufferPool'))) {
      return;
    }
    debugPrintThrottled(message, wrapWidth: wrapWidth);
  };

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ZonSplashScreen(), // Arranca en el Splash 00
  ));
}

// ==========================================
// 00 | SPLASH SCREEN
// ==========================================
class ZonSplashScreen extends StatefulWidget {
  const ZonSplashScreen({super.key});

  @override
  State<ZonSplashScreen> createState() => _ZonSplashScreenState();
}

class _ZonSplashScreenState extends State<ZonSplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  VideoPlayerController? _videoController;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ZonOnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZonColors.obsidianBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ZŌN',
                style: TextStyle(
                  fontFamily: 'Serif', 
                  fontSize: 48, 
                  fontWeight: FontWeight.bold, 
                  color: ZonColors.bone,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your focus.',
                style: TextStyle(fontSize: 16, color: ZonColors.bone60, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ENRUTADOR PRINCIPAL DEL ONBOARDING (TODAS LAS PANTALLAS)
// ==========================================
class ZonOnboardingScreen extends StatefulWidget {
  const ZonOnboardingScreen({super.key});

  @override
  State<ZonOnboardingScreen> createState() => _ZonOnboardingScreenState();
}

class _ZonOnboardingScreenState extends State<ZonOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
 List<VideoPlayerController?> _videoControllers = [];
VideoPlayerController? _currentVideoController;
  // Total de pasos en el flujo lineal
  final int _totalSteps = 11; 
  double _scrollHours = 4.0;
  String _selectedLandscape = 'Rainforest';
  String? _selectedAttentionOption = 'The pre-sleep doomscroll';
  List<String> _selectedGoals = [
  'Deep-work hours',
  'A calmer evening',
  'To build something that lives'
];
// Mapeo exacto de tus 17 assets
  final List<String> _videoAssets = [
    'assets/splash-bg.mp4',       // Index 0
    'assets/splash-bg.mp4',    // Index 1
    'assets/splash-bg.mp4',         // Index 2
    'assets/splash-bg.mp4',         // Index 3
    'assets/splash-bg.mp4',         // Index 4
    'assets/splash-bg.mp4',         // Index 5
    'assets/splash-bg.mp4',         // Index 6
    'assets/splash-bg.mp4',         // Index 7
    'assets/splash-bg.mp4',         // Index 8
    'assets/splash-bg.mp4',        // Index 9
    'assets/splash-bg.mp4',        // Index 10
    'assets/splash-bg.mp4',        // Index 11
    'assets/splash-bg.mp4',  // Index 12
    'assets/splash-bg.mp4',        // Index 13
    'assets/splash-bg.mp4',        // Index 14
    'assets/splash-bg.mp4',        // Index 15
    'assets/splash-bg.mp4',        // Index 16
  ];
@override
void initState() {
  super.initState();
  // Inicializa únicamente el primer video al entrar a la pantalla
  _loadVideoForIndex(0);
}

@override
void dispose() {
  _currentVideoController?.dispose();
  _pageController.dispose();
  super.dispose();
}

// Método maestro para cambiar de video limpiando la memoria de la GPU inmediatamente
Future<void> _loadVideoForIndex(int index) async {
  // 1. Si ya hay un video corriendo, lo detenemos y lo destruimos de inmediato
  if (_currentVideoController != null) {
    final oldController = _currentVideoController;
    _currentVideoController = null;
    if (mounted) setState(() {}); // Deja la pantalla en negro un milisegundo de transición
    await oldController?.pause();
    await oldController?.dispose();
  }

  // 2. Control de seguridad por si el índice se sale del rango de los 17 videos
  if (index >= _videoAssets.length) return;

  try {
    // 3. Crear el nuevo controlador de manera individual
    final controller = VideoPlayerController.asset(_videoAssets[index]);
    
    // CONFIGURACIÓN ANTI-BLOQUEO PARA INFINIX:
    // Le quitamos el volumen antes de inicializar para evitar el conflicto de Audio Focus
    await controller.setVolume(0.0);
    await controller.initialize();
    
    if (mounted) {
      await controller.setLooping(true);
      await controller.play();
      
      setState(() {
        _currentVideoController = controller;
      });
    }
  } catch (e) {
    debugPrint('Error cargando video del paso $index: $e');
  }
}
// Inicializador individual controlado y asíncrono
Future<void> _initSingleController(int index, String assetPath) async {
  try {
    final controller = VideoPlayerController.asset(assetPath);
    _videoControllers[index] = controller;
    
    await controller.initialize();
    
    if (mounted) {
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();
      
      // Forzamos reactividad refrescando la referencia de la lista
      setState(() {
        _videoControllers = List<VideoPlayerController?>.from(_videoControllers);
      });
    }
  } catch (error) {
    debugPrint('Error crítico inicializando el video index $index ($assetPath): $error');
  }
}

// Carga secuencial diferida para el resto de los 16 videos
void _initRemainingControllers(List<String> assets) async {
  for (int i = 1; i < assets.length; i++) {
    if (!mounted) return;
    
    // Le damos un respiro de 150 milisegundos entre video y video a la CPU/GPU
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (!mounted) return;
    await _initSingleController(i, assets[i]);
  }
}
 

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZonColors.obsidianBg,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Navegación controlada estrictamente por botones
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _loadVideoForIndex(index);
              if (index == 7) {
  // Simula la carga de datos durante 3 segundos y luego avanza sola a la siguiente pantalla
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted && _currentIndex == 7) {
      _nextPage(); 
    }
  });
}
            },
            children: [
              _buildScreen1(),               // Index 0: 1.jpg - Get Started
              _buildScreen2(),
           _buildScreen3(),
             _buildScreen4(),
              _buildScreen5(),
             _buildScreen6(),
              _buildScreen7(),
               _buildScreen8(),
              _buildScreen9(),               // Index 8: 9.jpg - This is yours now
              _buildScreen10(),              // Index 9: 10.jpg - Your habitat just grew
              _buildScreen11(),              // Index 10: 11.png - In 30 days...
              _buildScreen12(),              // Index 11: 12.png - Your habitat is ready to grow
              _buildScreen13(),              // Index 12: 13.jpg - Setup Account
             // _buildPhoneEmailFormScreen(),  // Index 13: SUBPANTALLA DE FORMULARIO MANUAL
              _buildScreen14(),              // Index 14: 14.jpg - Screen Time Access
              _buildScreen15(),              // Index 15: 15.jpg - What pulls you in?
              _buildScreen16(),              // Index 16: 16.jpg - A nudge, never noise
              _buildScreen17(),              // Index 17: 17.jpg - How did you find us?
            ],
          ),

          // Barra superior global (No se muestra en la pantalla de bienvenida 1.jpg)
          if (_currentIndex > 0)
            Positioned(
              top: 60, left: 24, right: 24,
              child: _buildTopProgressBar(),
            ),
        ],
      ),
    );
  }

  // Indicador discontinuo superior adaptable
  Widget _buildTopProgressBar() {
    int stepProgress = _currentIndex;
    // Normalizamos el índice si está en la pantalla del formulario dinámico
    if (_currentIndex > 13) stepProgress = _currentIndex - 1;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ZonColors.bone, size: 20),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: List.generate(_totalSteps, (index) {
              bool isCurrentOrPast = index <= (stepProgress - 1);
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isCurrentOrPast ? ZonColors.bone : ZonColors.bone.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Componente Reutilizable: Botón Translúcido de Vidrio Blurry
  Widget _buildGlassButton({required String text, required VoidCallback onTap, Color? textColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity, height: 60,
          decoration: BoxDecoration(
            color: ZonColors.GlassBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: ZonColors.GlassBorder),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: onTap,
            child: Text(
              text,
              style: TextStyle(color: textColor ?? ZonColors.bone, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  // Componente Reutilizable: Celdas de selección (Checkbox / Radio)
  Widget _buildSelectionTile({required String text, required Widget icon, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isSelected ? ZonColors.bone.withOpacity(0.15) : ZonColors.GlassBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? ZonColors.gold.withOpacity(0.5) : ZonColors.GlassBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  icon,
                  const SizedBox(width: 16),
                  Expanded(child: Text(text, style: const TextStyle(color: ZonColors.bone, fontSize: 16, fontWeight: FontWeight.w500))),
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? ZonColors.gold : ZonColors.bone40, width: 2),
                      color: isSelected ? ZonColors.gold : Colors.transparent,
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 14, color: ZonColors.obsidian) : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// ==========================================
// PANTALLA 1: Your habitat is waiting
// ==========================================
// ==========================================
// PANTALLA 1: Your habitat is waiting
// ==========================================
Widget _buildScreen1() {
  // Comprobación ultra-segura: si la lista no está lista o no tiene el índice 0, devuelve null
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black, // Respaldo mientras el video inicializa
    body: Stack(
      children: [
        // --- CAPA 1: EL VIDEO DE FONDO DINÁMICO (Usando la lista indexada) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.20), // El filtro 0.2 de tu diseño
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller), // Controlador de la lista indexada
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(
      color: Colors.black, // Fondo negro seguro en lugar de buscar 'assets/1.jpg'
    ),
                ),
        ),

        // --- CAPA 2: DISEÑO DE TEXTOS Y BOTÓN (Idéntico a tu captura 1.jpg) ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Estira el botón al ancho completo de la UI
              children: [
                // Empuja el bloque central hacia la posición exacta de la foto
                const Spacer(flex: 4),
                
                // Título Principal Centrado
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Serif', 
                      fontSize: 42, 
                      color: ZonColors.bone, 
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: 'Your '),
                      TextSpan(
                        text: 'habitat\n', 
                        style: TextStyle(
                          fontStyle: FontStyle.italic, 
                          color: ZonColors.gold, // Tu color dorado corporativo
                        ),
                      ),
                      TextSpan(text: 'is waiting.'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtítulo descriptivo
                Text(
                  'Disconnect. Step into the ZŌN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ZonColors.bone60, 
                    fontSize: 16, 
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                // Empuja el botón hacia la parte inferior
                const Spacer(flex: 3),
                
                // Botón Premium "Get Started" con estilo de píldora idéntico a los de la 13
                _buildGlassButtonFormatoImagen(
                  text: 'Get Started →',
                  icon: Icons.arrow_forward, // No se usa porque showIcon es false
                  showIcon: false,
                  onTap: _nextPage, // Tu función existente para avanzar
                ),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


// PANTALLA 2: Your habitat is waiting (Sky/Nature version)
// ==========================================
// ==========================================
// PANTALLA 2: Your habitat is waiting (Sky/Nature version)
// ==========================================
// PANTALLA 2: Your habitat is waiting (Sky/Nature version)
// ==========================================
Widget _buildScreen2() {
  // Comprobación ultra-segura para el índice 1
   final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black, // Respaldo de carga
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO COMPLETO (Usando la lista indexada) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.15), // Filtro sutil para no comprometer legibilidad
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller), // Controlador de la lista indexada
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(
      color: Colors.black, // Fondo negro seguro en lugar de buscar 'assets/1.jpg'
    ),
                ),
        ),

        // --- CAPA 2: BOTÓN DE MUTE EN LA ESQUINA SUPERIOR DERECHA ---
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    controller != null && controller.value.volume > 0.0 
                        ? Icons.volume_up 
                        : Icons.volume_off, 
                    color: ZonColors.bone, 
                    size: 16,
                  ),
                  onPressed: () {
                    // Lógica mutear/desmutear sobre el índice correcto de la lista
                    if (controller != null) {
                      double currentVolume = controller.value.volume;
                      controller.setVolume(currentVolume == 0.0 ? 1.0 : 0.0);
                      setState(() {}); // Actualiza el icono del botón de mute
                    }
                  },
                ),
              ),
            ),
          ),
        ),

        // --- CAPA 3: CONTENIDO ESTRUCTURAL (Alineado a la Izquierda) ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los botones al ancho completo
              children: [
                // Controlamos la distancia exacta del bloque superior de texto
                const SizedBox(height: 80),
                
                // Título Alineado a la Izquierda con RichText
                RichText(
                  textAlign: TextAlign.start,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Serif', 
                      fontSize: 42, 
                      color: ZonColors.bone, 
                      height: 1.15,
                    ),
                    children: [
                      TextSpan(text: 'Your '),
                      TextSpan(
                        text: 'habitat\n', 
                        style: TextStyle(
                          fontStyle: FontStyle.italic, 
                          color: ZonColors.gold,
                        ),
                      ),
                      TextSpan(text: 'is waiting.'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // Subtítulo descriptivo de dos líneas (Alineado a la izquierda)
                Text(
                  'Every minute you focus, your animal\nlives.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: ZonColors.bone60, 
                    fontSize: 16, 
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const Spacer(), // Empuja el área de interacción al fondo de la pantalla
                
                // Botón Principal: Begin →
                _buildGlassButtonFormatoImagen(
                  text: 'Begin →',
                  icon: Icons.arrow_forward,
                  showIcon: false,
                   onTap: _nextPage, // Tu lógica para saltar a la Pantalla 3
                ),
                
                const SizedBox(height: 18),
                
                // Enlace secundario inferior: See how a session works ↓
                GestureDetector(
                  onTap: () {
                    // Acción para abrir hoja explicativa o hacer scroll
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'See how a session works ↓',
                        style: TextStyle(
                          color: ZonColors.bone60.withOpacity(0.7),
                          fontSize: 13,
                          letterSpacing: 0.2,
                          decoration: TextDecoration.underline, // Da ese aspecto sutil de link interactivo
                          decorationColor: ZonColors.bone40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  

Widget _buildScreen3() {
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: EL VIDEO DE FONDO DINÁMICO (Optimizado para Infinix) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35), // Un poco más oscuro para que resalten los textos superiores
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              :  SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: CONTENIDO INTERNO DE LA PANTALLA ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Espacio para la barra de progreso superior global
                const SizedBox(height: 60), 
                
                // Título Principal Centrado
                const Text(
                  'How much of your day\nvanishes to the scroll?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: ZonColors.bone,
                    height: 1.3,
                  ),
                ),
                
                const Spacer(flex: 2),

                // --- BLOQUE CENTRAL: INDICADOR DE HORAS DINÁMICO ---
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _scrollHours.round().toString(),
                          style: const TextStyle(
                            fontSize: 84,
                            fontWeight: FontWeight.w300,
                            color: ZonColors.gold, // Tu color dorado corporativo
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'h',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: ZonColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A DAY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ZonColors.bone.withOpacity(0.4),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // --- SLIDER PERSONALIZADO ESTILO PREMIUM ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      // Etiquetas de los extremos (1h y 12h+)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1h', style: TextStyle(color: ZonColors.bone.withOpacity(0.3), fontSize: 12)),
                          Text('12h+', style: TextStyle(color: ZonColors.bone.withOpacity(0.3), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // El Slider con estilos personalizados reflejando la captura
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 12,
                          activeTrackColor: ZonColors.gold.withOpacity(0.8),
                          inactiveTrackColor: Colors.white.withOpacity(0.1),
                          thumbColor: ZonColors.gold,
                          overlayColor: ZonColors.gold.withOpacity(0.2),
                          // Diseñamos el contenedor de cápsula blurry para el fondo del slider
                          trackShape: const RoundedRectSliderTrackShape(),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                        ),
                        child: Slider(
                          value: _scrollHours,
                          min: 1.0,
                          max: 12.0,
                          onChanged: (value) {
                            setState(() {
                              _scrollHours = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Subtítulo descriptivo inferior
                Text(
                  'Be honest — this is just between you and your\nhabitat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ZonColors.bone.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const Spacer(flex: 2),

                // Botón Premium "Continue" usando tu componente reutilizable
                _buildGlassButtonFormatoImagen(
                  text: 'Continue →',
                  icon: Icons.arrow_forward,
                  showIcon: false,
                  onTap: _nextPage,
                ),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _buildScreen4() {
  final controller = _currentVideoController;

  // Cálculo dinámico proporcional basado en la respuesta del slider anterior
  // Si 4h = 8 años, significa que multiplicamos las horas por 2.
  final int estimatedYears = (_scrollHours * 2).round();

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: EL VIDEO DE FONDO DINÁMICO (Optimizado para Infinix) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.40), // Filtro oscuro idéntico a la captura 4.jpg
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              :  SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: CONTENIDO INTERNO ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Margen superior para respetar la barra global discontinua
                const SizedBox(height: 60),

                // Texto superior en tamaño pequeño y centrado
                Text(
                  'At ${_scrollHours.round()}h a day,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: ZonColors.bone.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(flex: 1),

                // --- BLOQUE CENTRAL: EL CONTADOR DE AÑOS IMPACTANTE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Símbolo de aproximado (≈)
                    Text(
                      '≈ ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: ZonColors.bone.withOpacity(0.4),
                      ),
                    ),
                    // Número de años gigante
                    Text(
                      '$estimatedYears',
                      style: const TextStyle(
                        fontSize: 110, // Tamaño masivo para emular la tipografía original
                        fontWeight: FontWeight.w200,
                        color: ZonColors.bone,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Etiqueta "years"
                    const Text(
                      'years',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: ZonColors.bone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Texto descriptivo de cierre del bloque central
                Text(
                  'of your life, gone to the scroll.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: ZonColors.bone.withOpacity(0.9),
                  ),
                ),

                const Spacer(flex: 2),

                // --- TEXTO EMOCIONAL EN CURSIVA (SERIF) ---
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Serif', // Tu fuente Serif estilizada
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      color: ZonColors.bone,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: 'Time your habitat helps you\ntake '),
                      TextSpan(
                        text: 'back.',
                        style: TextStyle(
                          color: ZonColors.gold, // Remate en tu color dorado corporativo
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Mini aclaración en la parte inferior del bloque emocional
                Text(
                  'Based on your waking years.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: ZonColors.bone.withOpacity(0.3),
                  ),
                ),

                const Spacer(flex: 2),

                // Botón Premium "Continue" usando tu componente base
                _buildGlassButtonFormatoImagen(
                  text: 'Continue →',
                  icon: Icons.arrow_forward,
                  showIcon: false,
                  onTap: _nextPage,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
 
Widget _buildScreen5() {
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: EL VIDEO DE FONDO DINÁMICO (Optimizado contra bloqueos) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45), // Atenuación controlada para lectura de celdas
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ DE SELECCIÓN RESPONSIVA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(), // Scroll limpio que solo se activa si falta espacio
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0), // Padding vertical optimizado
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30, // Fuerza la ocupación de pantalla adaptable
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Margen dinámico controlado para respetar la barra superior de progreso discontinua global
                        const SizedBox(height: 50),

                        // Texto introductorio pequeño
                        Text(
                          'Every session you keep feeds one place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14, // Ajustado sutilmente para balance de aspecto
                            fontWeight: FontWeight.w300,
                            color: ZonColors.bone.withOpacity(0.7),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Título en Cursiva Elegante (Serif)
                        const Text(
                          'Which landscape is yours?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 30, // Reducido de 34 a 30 para evitar desbordar anchos en pantallas chicas
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: ZonColors.bone,
                          ),
                        ),

                        // Separador controlado en lugar de un Spacer rígido inicial
                        const SizedBox(height: 25),

                        // --- LISTADO DE OPCIONES TRANSLÚCIDAS (GLASS TILES REOPTIMIZADAS) ---
                        _buildLandscapeTile(
                          title: 'Desert',
                          subtitle: 'Atacama  ·  vast & still',
                          icon: Icons.wb_sunny_outlined,
                          value: 'Desert',
                        ),
                        _buildLandscapeTile(
                          title: 'Rainforest',
                          subtitle: 'Amazon  ·  dense & alive',
                          icon: Icons.nature_outlined,
                          value: 'Rainforest',
                        ),
                        _buildLandscapeTile(
                          title: 'Coast',
                          subtitle: 'Pacífico  ·  open & rhythmic',
                          icon: Icons.waves_outlined,
                          value: 'Coast',
                        ),
                        _buildLandscapeTile(
                          title: 'Highlands',
                          subtitle: 'Andes  ·  clear & high',
                          icon: Icons.terrain_outlined,
                          value: 'Highlands',
                        ),

                        // Este componente absorbe el espacio sobrante estirando el layout de forma segura
                        const Expanded(child: SizedBox(height: 20)),

                        // Recordatorio inferior discreto
                        Text(
                          "Don't worry, you can change it later.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: ZonColors.bone.withOpacity(0.4),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Botón Estilo Premium de Vidrio "Go deeper"
                        _buildGlassButtonFormatoImagen(
                          text: 'Go deeper →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage,
                        ),

                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- COMPONENTE INTERNO REUTILIZABLE CON MEDIDAS ADAPTADAS ---
Widget _buildLandscapeTile({
  required String title,
  required String subtitle,
  required IconData icon,
  required String value,
}) {
  bool isSelected = _selectedLandscape == value;

  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0), // Ajustado de 14 a 10 para ahorrar 16px críticos en total
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20), // Radio unificado más balanceado
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLandscape = value;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Reducido vertical de 18 a 14
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.08) : ZonColors.GlassBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? ZonColors.bone.withOpacity(0.4) : ZonColors.GlassBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: ZonColors.bone.withOpacity(isSelected ? 0.9 : 0.6), size: 22),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: ZonColors.bone,
                          fontSize: 17,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: ZonColors.bone.withOpacity(0.4),
                          fontSize: 12,
                          fontFamily: 'Courier',
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Círculo Radio Indicador
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ZonColors.bone.withOpacity(isSelected ? 0.8 : 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected 
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ZonColors.bone,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  
  
Widget _buildScreen6() {
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO DINÁMICO ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45),
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ DE ATENCIÓN BLINDADA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),

                        const Text(
                          'Where does your attention\ngo?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: ZonColors.bone,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // --- LISTADO DE OPCIONES TRANSLÚCIDAS ---
                        _buildAttentionTile('Social media'),
                        _buildAttentionTile('Endless scrolling'),
                        _buildAttentionTile('The pre-sleep doomscroll'),
                        _buildAttentionTile("Work that won't stay focused"),
                        _buildAttentionTile('A bit of everything'),

                        const SizedBox(height: 15),

                        // --- CAPA EMOCIONAL DINÁMICA CON ANIMACIÓN NATIVA ---
                        // Si se selecciona la opción de la captura, la opacidad pasa a 1.0; si no, a 0.0 de forma suave.
                        AnimatedOpacity(
                          opacity: _selectedAttentionOption == 'The pre-sleep doomscroll' ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Serif',
                                    fontSize: 22,
                                    fontStyle: FontStyle.italic,
                                    color: ZonColors.bone,
                                    height: 1.3,
                                  ),
                                  children: [
                                    TextSpan(text: 'Yeah. The hour before sleep is the '),
                                    TextSpan(
                                      text: 'hardest\none to protect.',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: ZonColors.bone.withOpacity(0.5),
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: '81.5% ',
                                      style: TextStyle(
                                        color: ZonColors.bone, 
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: 'lose it too.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Expanded(child: SizedBox(height: 20)),

                        // Botón Estilo Premium de Vidrio "Continue"
                        _buildGlassButtonFormatoImagen(
                          text: 'Continue →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage,
                        ),

                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
// --- COMPONENTE INTERNO REUTILIZABLE: CELDA DE ATENCIÓN PREMIUM ---
Widget _buildAttentionTile(String optionText) {
  bool isSelected = _selectedAttentionOption == optionText;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0), // Separación vertical optimizada anti-desbordes
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedAttentionOption = optionText;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16), // Relleno equilibrado
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.08) : ZonColors.GlassBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? ZonColors.bone.withOpacity(0.5) : ZonColors.GlassBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: ZonColors.bone.withOpacity(isSelected ? 0.95 : 0.7),
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                
                // Indicador de Check / Círculo según estado de la captura
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ZonColors.bone.withOpacity(isSelected ? 0.8 : 0.2),
                      width: 1.5,
                    ),
                    color: isSelected ? ZonColors.bone : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.black, // Check negro contrastado como en la captura
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
 
 Widget _buildScreen7() {
  final controller = _currentVideoController;

  // Mapeo para transformar los IDs técnicos a la versión poética en cursiva de la captura
  final Map<String, String> poeticNames = {
    'Deep-work hours': 'Deep work',
    'A calmer evening': 'Calmer evenings',
    'Time with people, not screens': 'Time with people',
    'A streak I keep': 'A streak',
    'To build something that lives': 'Something that lives',
  };

  // Construir la cadena dinámica inferior basada en la selección (ej: "Deep work. Calmer evenings. Something that lives.")
  String summaryText = _selectedGoals
      .map((g) => poeticNames[g] ?? g)
      .join('. ');
  if (summaryText.isNotEmpty) {
    summaryText += '.'; // Remate con punto final
  }

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO DINÁMICO ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45),
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ SELECCIÓN MÚLTIPLE RESPONSIVA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),

                        // Título Principal
                        const Text(
                          'What do you want back?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: ZonColors.bone,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtítulo indicador
                        Text(
                          'Pick more than one.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: ZonColors.bone.withOpacity(0.5),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- LISTADO DE OPCIONES (GLASS TILES MÚLTIPLES) ---
                        _buildMultiSelectTile('Deep-work hours'),
                        _buildMultiSelectTile('A calmer evening'),
                        _buildMultiSelectTile('Time with people, not screens'),
                        _buildMultiSelectTile('A streak I keep'),
                        _buildMultiSelectTile('To build something that lives'),

                        const SizedBox(height: 15),

                        // --- BLOQUE EMOCIONAL DINÁMICO DE TEXTO ---
                        AnimatedOpacity(
                          opacity: _selectedGoals.isNotEmpty ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                summaryText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 22,
                                  fontStyle: FontStyle.italic,
                                  color: ZonColors.bone,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: ZonColors.bone.withOpacity(0.5),
                                      height: 1.4,
                                    ),
                                    children: const [
                                      TextSpan(text: "You're in the right place. "),
                                      TextSpan(
                                        text: '82% ',
                                        style: TextStyle(
                                          color: ZonColors.bone,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "have tried an app that didn't stick — this one grows something you won't want to lose.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Expanded(child: SizedBox(height: 20)),

                        // Botón Estilo Premium de Vidrio "Continue"
                        _buildGlassButtonFormatoImagen(
                          text: 'Continue →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage,
                        ),

                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- COMPONENTE INTERNO REUTILIZABLE: CELDA CHECKBOX PREMIUM ---
Widget _buildMultiSelectTile(String optionText) {
  bool isSelected = _selectedGoals.contains(optionText);

  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0), // Padding optimizado anti-desbordes
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedGoals.remove(optionText);
              } else {
                _selectedGoals.add(optionText);
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.08) : ZonColors.GlassBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? ZonColors.bone.withOpacity(0.5) : ZonColors.GlassBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: ZonColors.bone.withOpacity(isSelected ? 0.95 : 0.7),
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                
                // Indicador Cuadrado Redondeado Checkbox (Estilo iOS Premium de la captura)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6), // Radio sutil para simular la imagen
                    border: Border.all(
                      color: ZonColors.bone.withOpacity(isSelected ? 0.8 : 0.2),
                      width: 1.5,
                    ),
                    color: isSelected ? ZonColors.bone : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.black, // Check interno oscuro idéntico a la imagen 7.jpg
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
 Widget _buildScreen8() {
  final controller = _currentVideoController;

  // NOTA DE DESARROLLO: Para simular el efecto de la captura de forma real en la app:
  // Puedes usar un valor de progreso de un AnimationController (ej. _loadingProgress de 0.0 a 1.0)
  // Para este diseño base, usaremos un valor estático simulando el final (1.0 / 100%) como se ve en la captura.
  const double progressValue = 1.0; 
  final int percentText = (progressValue * 100).round();

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO DINÁMICO (Con atenuación de carga oscura) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.60), // Más oscuro para centrar la atención en la carga
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ DE CARGA RESPONSIVA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Espacio superior para respetar la barra discontinua global
                        const SizedBox(height: 50),

                        // Título de la pantalla de carga
                        const Text(
                          'Building your landscape...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: ZonColors.bone,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const Spacer(flex: 2),

                        // --- BLOQUE CENTRAL: PORCENTAJE + ANILLO DE PROGRESO ---
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Texto del porcentaje en color dorado/ámbar corporativo
                            Text(
                              '$percentText%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: ZonColors.gold, // Tu color ámbar/dorado de Zon
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Anillo de progreso personalizado
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: progressValue, // Controlado por tu animación
                                strokeWidth: 3.5,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(ZonColors.gold),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(flex: 3),

                        // --- CAPA INFERIOR: CHECKLIST DE CONFIGURACIÓN ---
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLoadingCheckItem('Your living habitat', true),
                            _buildLoadingCheckItem('Your first soundscape', true),
                            _buildLoadingCheckItem('A session shaped to your evenings', true),
                          ],
                        ),

                        const Spacer(flex: 1),

                        // Texto de estado de cierre de pie de página
                        Text(
                          'Making this yours...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: ZonColors.bone.withOpacity(0.4),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- COMPONENTE INTERNO: FILA DE ITEM DE CARGA CON SU CHECK ---
Widget _buildLoadingCheckItem(String labelText, bool isCompleted) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0), // Separación equilibrada anti-desbordes
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Círculo indicador del Check
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.white.withOpacity(0.12) : Colors.transparent,
            border: Border.all(
              color: isCompleted ? ZonColors.bone.withOpacity(0.5) : ZonColors.bone.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: 15,
                  color: ZonColors.bone, // Check sutil claro como en la captura 8.jpg
                )
              : null,
        ),
        const SizedBox(width: 16),
        
        // Texto descriptivo del proceso
        Expanded(
          child: Text(
            labelText,
            style: TextStyle(
              color: ZonColors.bone.withOpacity(isCompleted ? 0.9 : 0.4),
              fontSize: 16,
              fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w300,
            ),
          ),
        ),
      ],
    ),
  );
}
  
  
  
  Widget _buildScreenIntermedias(int assetNum, String titulo, String subtitulo) {
    return Container(
      color: ZonColors.obsidianBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(titulo, style: const TextStyle(fontFamily: 'Serif', fontSize: 34, color: ZonColors.bone)),
              const SizedBox(height: 10),
              Text(subtitulo, style: TextStyle(color: ZonColors.bone60, fontSize: 16)),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image(image: AssetImage('assets/$assetNum.jpg'), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              _buildGlassButton(text: 'Next →', onTap: _nextPage),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PANTALLA 9: This is yours now
  // ==========================================
Widget _buildScreen9() {
  final controller = _currentVideoController;

  // Obtenemos el paisaje guardado del paso 5 (por defecto Rainforest si es nulo)
  final String landscape = _selectedLandscape ?? 'Rainforest';
  
  // Definimos la localización poética según el paisaje para el tag superior
  String locationTag = 'AMAZON  ·  RAINFOREST';
  if (landscape == 'Desert') locationTag = 'ATACAMA  ·  DESERT';
  if (landscape == 'Coast') locationTag = 'PACÍFICO  ·  COAST';
  if (landscape == 'Highlands') locationTag = 'ANDES  ·  HIGHLANDS';

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO DINÁMICO (Específico del paisaje elegido) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.40), // Filtro de opacidad premium para lectura nítida
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ TEXTUAL PREMIUM RESPONSIVA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Margen superior para respetar el indicador de progreso discontinuo global
                        const SizedBox(height: 50),

                        // Etiqueta superior con icono de brújula o localización (Estilo Monospace Courier)
                        Row(
                          children: [
                            Icon(
                              Icons.explore_outlined, 
                              size: 14, 
                              color: ZonColors.bone.withOpacity(0.6)
                            ),
                            const SizedBox(width: 6),
                            Text(
                              locationTag,
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: ZonColors.bone.withOpacity(0.6),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 22),

                        // Título de propiedad en Cursiva Elegante (Serif)
                        const Text(
                          'This is yours now.',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 38, // Tamaño destacado de la captura 9.jpg
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: ZonColors.bone,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Cuerpo del mensaje explicativo adaptativo
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w300,
                              color: ZonColors.bone.withOpacity(0.85),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: 'Your ${landscape.toLowerCase()}, fully awake — '),
                              const TextSpan(
                                text: 'every session you keep brings it more alive.',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Advertencia/Regla del hábitat secundaria desvanecida
                        Text(
                          'Skip too many and it fades.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: ZonColors.bone.withOpacity(0.4),
                          ),
                        ),

                        // El Spacer flexible absorbe todo el fondo del paisaje (rio/bosque) de forma segura
                        const Expanded(child: SizedBox(height: 40)),

                        // Botón Estilo Premium de Vidrio Ovalado personalizado de la captura
                        _buildGlassButtonFormatoImagen(
                          text: "This one's mine →",
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage,
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// Método dummy de ejemplo para conectar el fin del onboarding
void _finalizeOnboarding() {
  // Aquí manejas la navegación al Home de la app o Dashboard principal.
  // Navigator.of(context).pushReplacement(...);
}
  // ==========================================
  // PANTALLA 10: Your habitat just grew
  // ==========================================
Widget _buildScreen10() {
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.55),
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ CONTROLADA SIN DESBORDAMIENTOS ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso
                    const SizedBox(height: 35),

                    // --- DIORAMA CENTRAL PEADO ABAJO ---
                    Expanded(
                      child: Align(
                        // CAMBIO CLAVE: Cambiamos 'Center' por 'Align' apuntando al fondo (bottomCenter)
                        alignment: Alignment.bottomCenter, 
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: availableHeight * 0.60, // Mantiene el tamaño grande que querías
                          ),
                          child: AspectRatio(
                            aspectRatio: _currentVideoController?.value.aspectRatio ?? 1.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: const LocalTransitionVideoWidget(
                                videoPath: 'assets/assets-s9-transition.mp4',
                                opacity: 0.55,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // REDUCIDO: Bajamos este espacio al mínimo para que el video toque casi el texto
                    const SizedBox(height: 0), 

                    // --- BLOQUE INFERIOR ULTRA COMPACTO ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título principal en Serif
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 32,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: ZonColors.bone,
                            ),
                            children: [
                              TextSpan(text: 'Your habitat just '),
                              TextSpan(
                                text: 'grew.',
                                style: TextStyle(
                                  color: ZonColors.gold, 
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        // Subtexto descriptivo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "That's one session. Keep showing up, and it thrives.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: ZonColors.bone.withOpacity(0.6),
                              height: 1.25,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón "Continue"
                        _buildGlassButtonFormatoImagen(
                          text: 'Continue →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage,
                        ),
                        
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
 
 
  double _daysSliderValue = 9;
 
 
Widget _buildScreen11() {
  // Inicializadores de estado local para la animación automática del Slider
  double currentSliderValue = 1.0;

  return Scaffold(
    backgroundColor: const Color(0xFF07121A), // Color de fondo exacto de la imagen
    body: Stack(
      children: [
        // --- CAPA 1: FONDO SÓLIDO (REEMPLAZADO EL VIDEO DE FONDO) ---
        Positioned.fill(
          child: Container(
            color: const Color(0xFF07121A),
          ),
        ),

        // --- CAPA 2: INTERFAZ CONTROLADA SIN DESBORDAMIENTOS ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso
                    const SizedBox(height: 40),

                    // 1. ETIQUETA SUPERIOR: AMAZON · RAINFOREST
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 14,
                          color: Colors.greenAccent.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AMAZON  ·  RAINFOREST',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. TÍTULO PRINCIPAL ALINEADO A LA IZQUIERDA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(text: 'In 30 days, '),
                            TextSpan(
                              text: 'your',
                              style: TextStyle(
                                color: ZonColors.gold,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const TextSpan(text: ' habitat\ncould look like this.'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // --- TRABAJO INTERNO: DIORAMA Y SLIDER CON CARGA AUTOMÁTICA ---
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setStateInternal) {
                          // Al renderizar por primera vez, disparamos el ticker lento para incrementar el valor
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (currentSliderValue < 30.0) {
                              Future.delayed(const Duration(milliseconds: 5), () {
                                if (context.mounted) {
                                  setStateInternal(() {
                                    // Va sumando de manera progresiva y suave hasta llegar a 30
                                    currentSliderValue += 0.25;
                                    if (currentSliderValue > 30.0) currentSliderValue = 30.0;
                                  });
                                }
                              });
                            }
                          });

                          final displayDay = currentSliderValue.round();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 3. DIORAMA CENTRAL PEADO ABAJO CON BADGE AUTOMÁTICO
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: availableHeight * 0.45,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 0.7, // Proporción vertical de tarjeta de la imagen
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(32),
                                              child: const LocalTransitionVideoWidget(
                                                videoPath: 'assets/assets-s11-growth.mp4',
                                                opacity: 1.0,
                                              ),
                                            ),
                                          ),
                                          // Badge del día que cambia solo
                                          Positioned(
                                            top: 16,
                                            left: 20,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Day $displayDay',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 4. CONTROL DESLIZANTE (SLIDER) AUTOMÁTICO
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Day 1',
                                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: 4,
                                          activeTrackColor: ZonColors.gold,
                                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                                          thumbColor: ZonColors.gold,
                                          overlayColor: ZonColors.gold.withOpacity(0.2),
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                        ),
                                        child: Slider(
                                          value: currentSliderValue,
                                          min: 1.0,
                                          max: 30.0,
                                          onChanged: (value) {}, // Deshabilitado manual para dejar correr la carga
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Day 30',
                                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  'by Jun 29',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- BLOQUE INFERIOR ULTRA COMPACTO SECUENCIAL ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 5. BOTÓN SECUNDARIO DE TEXTO EN SERIF
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.02),
                                ],
                              ),
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                                children: [
                                  const TextSpan(text: 'Protect '),
                                  TextSpan(
                                    text: 'your calmer evenings.',
                                    style: TextStyle(
                                      color: ZonColors.gold,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 6. BOTÓN "Continue" ORIGINAL INTACTO EN LA SECUENCIA
                        _buildGlassButtonFormatoImagen(
                          text: 'Continue →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage, // Tu secuencia original funcionando directo
                        ),
                        
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
  
  
 Widget _buildScreen12() {
  return Scaffold(
    backgroundColor: const Color(0xFF07121A), // Fondo oscuro azabache azulado de la imagen
    body: Stack(
      children: [
        // --- CAPA 1: FONDO SÓLIDO (IDÉNTICO AL SCREEN 11) ---
        Positioned.fill(
          child: Container(
            color: const Color(0xFF07121A),
          ),
        ),

        // --- CAPA 2: INTERFAZ CON SCROLL DE ARRIBA A ABAJO ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso general (líneas de arriba)
                    const SizedBox(height: 40),

                    // 1. TÍTULO PRINCIPAL (Imagen 12)
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.25,
                        ),
                        children: [
                          TextSpan(
                            text: 'Your ',
                            style: TextStyle(color: ZonColors.gold),
                          ),
                          const TextSpan(text: 'habitat is ready to grow.\nKeep your '),
                          TextSpan(
                            text: 'calmer evenings\n',
                            style: TextStyle(color: ZonColors.gold),
                          ),
                          const TextSpan(text: 'and the streak you\'re starting.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. TARJETA CENTRAL BLURREADA / CONTENEDOR DE BLOQUEO (Your Habitat · Alive)
                    Container(
                      height: constraints.maxHeight * 0.32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        // Simulamos la tarjeta con un gradiente sutil simulando neblina/oscuridad
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.06),
                            Colors.white.withOpacity(0.02),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Stack(
                        children: [
                          // Contenido de la etiqueta superior izquierda dentro de la tarjeta
                          Positioned(
                            top: 16,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'YOUR HABITAT  ·  ALIVE',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          // Icono de candado y textos centrales
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.2),
                                    border: Border.all(color: ZonColors.gold.withOpacity(0.4), width: 1.5),
                                  ),
                                  child: Icon(Icons.lock_outline, color: ZonColors.gold, size: 24),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Unlock',
                                  style: TextStyle(
                                    color: ZonColors.gold,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "it's breathing — don't let it fade",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. CAPSULAS DE CONFIGURACIÓN (Habitat, Soundscape, Plan)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFeatureChip('Habitat:', 'Rainforest'),
                        _buildFeatureChip('Soundscape:', 'Night crickets'),
                        _buildFeatureChip('Plan:', 'Calmer evenings'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 4. BANNER VERDE DE DONACIÓN/REVENUE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1E1C).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ZonColors.colorVerdeEsmeralda.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.eco, color: ZonColors.colorVerdeEsmeralda, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                                children: [
                                  const TextSpan(text: 'A portion of our revenue funds real wildlife habitat — '),
                                  TextSpan(
                                    text: 'paid quarterly.',
                                    style: TextStyle(color: ZonColors.colorVerdeEsmeralda, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- INICIO DE IMAGEN 12_2 (SECCIÓN TIMELINE & PRECIOS) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'How your free trial works',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF112522),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ZonColors.colorVerdeEsmeralda.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check, color: ZonColors.colorVerdeEsmeralda, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'No payment due now',
                                style: TextStyle(color: ZonColors.colorVerdeEsmeralda, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 5. TIMELINE VERTICAL COPIADO DE LA IMAGEN
                    _buildTimelineRow(
                      title: 'Today',
                      subtitle: '— full access unlocked',
                      date: 'May 30',
                      isFirst: true,
                      isActive: true,
                    ),
                    _buildTimelineRow(
                      title: 'Day 5',
                      subtitle: '— we\'ll remind you',
                      date: 'Jun 4  ·  notification',
                      isActive: false,
                    ),
                    _buildTimelineRow(
                      title: 'Day 7',
                      subtitle: '— your plan begins, cancel anytime before',
                      date: 'Jun 6',
                      isLast: true,
                      isActive: false,
                    ),

                    const SizedBox(height: 24),

                    // 6. RECORDATORIOS INTERACTIVOS (Botones: 2 days before, etc.)
                    Text(
                      'When should we remind you before it ends?',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildReminderOption('2 days\nbefore', isSelected: true)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildReminderOption('1 day\nbefore', isSelected: false)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildReminderOption('Morning\nit ends', isSelected: false)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 7. TARJETA DE PLAN ANUAL (BEST VALUE)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.03),
                            border: Border.all(color: ZonColors.gold.withOpacity(0.5), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Annual', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('\$79.99 / year · about \$1.54 / week', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                                ],
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ZonColors.gold,
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -10,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: ZonColors.gold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BEST VALUE  ·  SAVE 44%',
                              style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 8. TARJETA DE PLAN SEMANAL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.02),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Weekly', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text('7-day free trial · ≈ \$11.99 / mo', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          ),
                          Text('\$2.77\n/wk', textAlign: TextAlign.right, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 9. PIE DE PÁGINA EMOCIONAL EN SERIF
                    Text(
                      "Don't let it fade.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Iconos de proveedores de pago (Apple / Google / Guest)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.apple, color: Colors.white.withOpacity(0.5), size: 16),
                        const SizedBox(width: 4),
                        Text('Apple', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                        const SizedBox(width: 16),
                        Icon(Icons.g_mobiledata, color: Colors.white.withOpacity(0.5), size: 24),
                        Text('Google', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                        const SizedBox(width: 16),
                        Text('continue as guest', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 10. BOTÓN PRINCIPAL ACCIÓN "Save your habitat →"
                    _buildGlassButtonFormatoImagen(
                      text: 'Save your habitat →',
                      icon: Icons.arrow_forward,
                      showIcon: false,
                     onTap: _nextPage,
                    ),

                    const SizedBox(height: 16),

                    // Textos legales pequeños del footer
                    Text(
                      '7-day free trial, then \$79.99/yr. Cancel anytime in Settings before Jun 6.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Prices shown in USD - localized to your country. ', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)),
                        Text('Terms', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, decoration: TextDecoration.underline)),
                        Text(' · ', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                        Text('Privacy', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, decoration: TextDecoration.underline)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 11. BOTÓN DE CIERRE O SALIDA "Not now ✕"
                    GestureDetector(
                    onTap: _nextPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Not now ✕',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- WIDGETS AUXILIARES PRIVADOS PARA MANTENER LIMPIO EL MÉTODO ---

Widget _buildFeatureChip(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
        ),
        const SizedBox(width: 8),
        Text('$label ', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

Widget _buildTimelineRow({required String title, required String subtitle, required String date, bool isFirst = false, bool isLast = false, required bool isActive}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? ZonColors.gold : Colors.transparent,
                border: Border.all(color: isActive ? ZonColors.gold : Colors.white.withOpacity(0.3), width: 2),
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: isActive ? ZonColors.gold : Colors.white.withOpacity(0.15),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
           padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14),
                    children: [
                      TextSpan(text: title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      TextSpan(text: ' $subtitle', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(color: isActive ? ZonColors.gold : Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildReminderOption(String text, {required bool isSelected}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: isSelected ? Colors.white.withOpacity(0.06) : Colors.transparent,
      border: Border.all(color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.15)),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1.2,
      ),
    ),
  );
}
  Widget _buildMetaChip({required String label, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: ZonColors.GlassBg, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: ZonColors.gold)),
          const SizedBox(width: 8),
          Text('$label ', style: TextStyle(color: ZonColors.bone40, fontSize: 14)),
          Text(value, style: const TextStyle(color: ZonColors.bone, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


// ==========================================
// PANTALLA 13: Create your account
// ==========================================
Widget _buildScreen13() {
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.65), // Un poco más oscuro para resaltar los botones de login
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ CONTROLADA SIN DESBORDAMIENTOS ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso
                    const SizedBox(height: 35),

                    // --- PARTE SUPERIOR: TEXTOS DE CREACIÓN DE CUENTA ---
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.left,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 36,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Create your account'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'So your habitat stays yours — on any device.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),

                    // Espacio expandido flexible para empujar los botones hacia abajo de forma limpia
                    const Spacer(),

                    // --- BLOQUE INFERIOR DE BOTONES (AUTENTICACIÓN) ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Botón principal: Use phone or email
                        _buildGlassButtonFormatoImagen(
                          text: 'Use phone or email',
                          icon: Icons.phone,
                          showIcon: false,
                            onTap: _nextPage,
                        ),

                        const SizedBox(height: 16),

                        // Divisor "or" intermedio
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.15), thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Botón: Continue with Apple
                        _buildSocialLoginButton(
                          text: 'Continue with Apple',
                          iconPath: Icons.apple, // O usa un SVG de Apple si lo tienes configurado
                          onTap: _nextPage,
                        ),

                        const SizedBox(height: 12),

                        // Botón: Continue with Google
                        _buildSocialLoginButton(
                          text: 'Continue with Google',
                          iconPath: Icons.g_mobiledata_rounded, 
                             onTap: _nextPage,
                        ),

                        const SizedBox(height: 12),

                        // Botón: Continue with Facebook
                        _buildSocialLoginButton(
                          text: 'Continue with Facebook',
                          iconPath: Icons.facebook,
                          iconColor: const Color(0xFF1877F2),
                         onTap: _nextPage,
                        ),

                        const SizedBox(height: 24),

                        // Textos de Términos y Condiciones
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'By continuing you agree to our '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), decoration: TextDecoration.underline),
                                ),
                                const TextSpan(text: ' and acknowledge our '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), decoration: TextDecoration.underline),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // Footer de login alternativo "Already have an account? Log in"
                        GestureDetector(
                          onTap: () {
                            // Acción para ir a pantalla de Login
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Log in',
                                  style: TextStyle(
                                    color: ZonColors.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- SUB-WIDGET AUXILIAR PARA LOS BOTONES SOCIALES TRASLÚCIDOS ---
Widget _buildSocialLoginButton({
  required String text,
  IconData? iconPath,
  Widget? iconWidget,
  Color iconColor = Colors.white,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null) iconWidget,
          if (iconPath != null) Icon(iconPath, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

/*Widget _buildScreen13() {
  return Scaffold(
    backgroundColor: Colors.black, // Fondo de respaldo por si el video tarda un instante en cargar
    body: Stack(
      children: [
        // --- CAPA 1: EL VIDEO EN HIGH-BACKGROUND (BOXFIT.COVER REAL) ---
        if (_videoController != null && _videoController!.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          )
        else
          // Imagen de fallback/placeholder estática mientras el video inicializa
          SizedBox.expand(
            child: Image.asset(
              'assets/13.jpg',
              fit: BoxFit.cover,
            ),
          ),

        // --- CAPA 2: FILTRO OSCURO SUTIL (Opcional, mejora contraste del texto) ---
        Container(
          color: Colors.black.withOpacity(0.15),
        ),

        // --- CAPA 3: TU UI CON EL DISEÑO EXACTO Y EFECTO GLASSMORPHISM ---
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50), // Espacio debajo de la barra de progreso
                
                // Título Principal (Estilo Serif elegante)
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontFamily: 'Serif', 
                    fontSize: 36, 
                    color: ZonColors.bone,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Subtítulo
                Text(
                  'So your habitat stays yours — on any device.',
                  style: TextStyle(
                    color: ZonColors.bone60, 
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const Spacer(), // Empuja el bloque de botones hacia abajo
                
                // Botón 1: Correo / Teléfono
                _buildGlassButtonFormatoImagen(
                  text: 'Use phone or email',
                  icon: Icons.phone_android_rounded,
                  showIcon: false, 
                  onTap: () => _goToPage(13), 
                ),
                
                // Separador "or"
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.07), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('or', style: TextStyle(color: ZonColors.bone40, fontSize: 14)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.07), thickness: 1)),
                    ],
                  ),
                ),
                
                // Botón 2: Apple
                _buildGlassButtonFormatoImagen(
                  text: 'Continue with Apple',
                  icon: Icons.apple,
                  onTap: () => _goToPage(14),
                ),
                const SizedBox(height: 12),
                
                // Botón 3: Google
                _buildGlassButtonFormatoImagen(
                  text: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded, 
                  iconColor: Colors.white, 
                  onTap: () => _goToPage(14),
                ),
                const SizedBox(height: 12),
                
                // Botón 4: Facebook
                _buildGlassButtonFormatoImagen(
                  text: 'Continue with Facebook',
                  icon: Icons.facebook,
                  iconColor: const Color(0xFF1877F2), 
                  onTap: () => _goToPage(14),
                ),
                
                const SizedBox(height: 24),
                
                // Textos legales de Términos y Privacidad
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'By continuing you agree to our Terms of Service and acknowledge our Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ZonColors.bone40, 
                      fontSize: 11, 
                      height: 1.4,
                    ),
                  ),
                ),
                
                const Spacer(), // Espacio entre legales y Login
                
                // Enlace inferior: Already have an account? Log in
                GestureDetector(
                  onTap: () {
                    // Navegación Login
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: ZonColors.bone60, fontSize: 15),
                        children: const [
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                              color: ZonColors.gold, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
*/

// --- HELPER COMPLEMENTARIO PARA CLONAR LOS BOTONES GLASS DE LA IMAGEN ---
Widget _buildGlassButtonFormatoImagen({
  required String text,
  required IconData icon,
  bool showIcon = true,
  Color? iconColor,
  required VoidCallback onTap,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(30), // Bordes estilo píldora como en la foto
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Desenfoque de fondo premium (Glassmorphism)
      child: Container(
        width: double.infinity,
        height: 58, // Altura exacta del botón de la captura
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06), // Fondo translúcido sutil
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.15), // Borde fino brillante característico del Glass
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showIcon) ...[
                    Icon(icon, color: iconColor ?? ZonColors.bone, size: 24),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      color: ZonColors.bone,
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Semi-bold para legibilidad sobre fondos oscuros
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
  // ==========================================
  // SUBPANTALLA: Formulario manual de Teléfono/Email
  // ==========================================
  Widget _buildPhoneEmailFormScreen() {
    return Container(
      color: ZonColors.obsidianBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text('Enter details', style: TextStyle(fontFamily: 'Serif', fontSize: 32, color: ZonColors.bone)),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: ZonColors.bone),
                decoration: InputDecoration(
                  labelText: 'Phone number or Email', labelStyle: TextStyle(color: ZonColors.bone40),
                  filled: true, fillColor: ZonColors.GlassBg,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ZonColors.GlassBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: ZonColors.gold)),
                ),
              ),
              const Spacer(),
              _buildGlassButton(text: 'Register & Continue →', onTap: () => _goToPage(14)), // Salta a Screen Time (Index 14)
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildScreen14() {
  final controller = _currentVideoController;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO (Secuencia Original) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), // Ajustado para dar contraste al texto y al prompt de iOS
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ DE USUARIO ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso general
                    const SizedBox(height: 35),

                    // --- ENCABEZADO Y TÍTULOS ---
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.left,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'One switch turns it on.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ZŌN needs Screen Time access to do the two things it promises.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 17),

                    // --- TARJETAS INFORMATIVAS TRANSLÚCIDAS ---
                    _buildPermissionInfoCard(
                      icon: Icons.trending_up_rounded,
                      title: 'See your focus',
                      description: 'Reads your daily screen-time totals so the home screen can show real progress.',
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionInfoCard(
                      icon: Icons.lock_outline_rounded,
                      title: 'Hold the line',
                      description: 'Lets ZŌN dark-out the apps you pick the moment a session starts.',
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionInfoCard(
                      icon: Icons.shield_outlined, // O Icons.security / Icons.shield_outlined
                      title: 'Totals only — never the content',
                      description: 'ZŌN sees how long, never what you do inside an app. Processed on-device.',
                    ),

                    const Spacer(),

                    // --- DIÁLOGO SIMULADO DE PERMISO NATIVO ("ZŌN" Would Like to Access...) ---
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: constraints.maxWidth * 0.9,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E).withOpacity(0.95), // Gris oscuro nativo de iOS
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0, bottom: 8.0),
                                  child: Text(
                                    '"ZŌN" Would Like to Access Screen Time',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                  child: Text(
                                    'Allowing ZŌN to access Screen Time may let it see your activity data and restrict content.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      height: 1.35,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                                const Divider(color: Colors.white24, height: 1, thickness: 0.5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                        child: const Text(
                                          'Don\'t Allow',
                                          style: TextStyle(color: Color(0xFF0A84FF), fontSize: 17, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                    Container(width: 0.5, height: 44, color: Colors.white24),
                                    Expanded(
                                      child: Container(
                                        // Highlight sutil de selección encima del botón nativo "Allow"
                                        color: const Color(0xFF0A84FF).withOpacity(0.15),
                                        child: TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                          child: const Text(
                                            'Allow',
                                            style: TextStyle(color: Color(0xFF0A84FF), fontSize: 17, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Flecha indicadora flotante e indicador de "Tap Allow" debajo del diálogo
                          Positioned(
                            bottom: -45,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_upward, color: Colors.white70, size: 16),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E1E2F),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF1E3A5F)),
                                  ),
                                  child: const Text(
                                    'Tap "Allow"',
                                    style: TextStyle(color: Color(0xFF6BA4FF), fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // --- BLOQUE INFERIOR ACCIÓN Y BOTONES ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGlassButtonFormatoImagen(
                          text: 'Allow Screen Time →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: _nextPage,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _nextPage,
                          child: Text(
                            'Maybe later',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- WIDGET REUTILIZABLE PARA LAS FILAS DE PERMISO ---
Widget _buildPermissionInfoCard({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.06),
          Colors.white.withOpacity(0.02),
        ],
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildPermissionInfo({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: ZonColors.GlassBg, shape: BoxShape.circle), child: Icon(icon, color: ZonColors.bone, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: ZonColors.bone, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: ZonColors.bone60, fontSize: 14, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // PANTALLA 15: What pulls you in?
  // ==========================================
  final List<String> _categories = ['Social', 'Video & streaming', 'Games', 'Entertainment', 'News & reading'];
  int _selectedCategoryIndex = 0;

 Widget _buildScreen15() {
  final controller = _currentVideoController;

  // Nota: Para producción, maneja estos estados (las categorías seleccionadas) 
  // en tu State o gestor de estados para que cambien dinámicamente al hacer onTap.
  final Map<String, bool> selectedCategories = {
    'Social': true,
    'Video & streaming': false,
    'Games': false,
    'Entertainment': false,
    'News & reading': false,
    'Shopping': false,
  };

  // Contamos cuántas categorías están seleccionadas para el indicador superior derecho
  final selectedCount = selectedCategories.values.where((v) => v).length;

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO (Fiel a la secuencia) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.55),
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ DE SELECCIÓN CON LISTA ADAPTATIVA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso de líneas
                    const SizedBox(height: 35),

                    // --- ENCABEZADO CON CONTADOR COMPACTO ---
                    const SizedBox(height: 20),
                    Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        RichText(
                          textAlign: TextAlign.left,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(text: 'What pulls you in?'),
                            ],
                          ),
                        ),
                        // Indicador superior derecho: "1 category"
                        Text(
                          '$selectedCount ${selectedCount == 1 ? 'category' : 'categories'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Subtexto descriptivo con el caracter "›"
                    Text(
                      'Pick the kinds of apps that go dark in a session. Tap › to fine-tune.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- LISTADO DE CATEGORÍAS TRANSLÚCIDAS (SCROLLABLE SI ES NECESARIO) ---
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildCategoryRow(
                            title: 'Social',
                            appCount: 8,
                            icon: Icons.chat_bubble_outline_rounded,
                            isSelected: selectedCategories['Social'] ?? false,
                            showAllBadge: true,
                            onTap: () {
                              // Tu lógica de setState para alternar selección
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryRow(
                            title: 'Video & streaming',
                            appCount: 6,
                            icon: Icons.play_circle_outline_rounded,
                            isSelected: selectedCategories['Video & streaming'] ?? false,
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryRow(
                            title: 'Games',
                            appCount: 12,
                            icon: Icons.videogame_asset_outlined,
                            isSelected: selectedCategories['Games'] ?? false,
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryRow(
                            title: 'Entertainment',
                            appCount: 9,
                            icon: Icons.movie_creation_outlined,
                            isSelected: selectedCategories['Entertainment'] ?? false,
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryRow(
                            title: 'News & reading',
                            appCount: 7,
                            icon: Icons.article_outlined,
                            isSelected: selectedCategories['News & reading'] ?? false,
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryRow(
                            title: 'Shopping',
                            appCount: 5,
                            icon: Icons.shopping_bag_outlined,
                            isSelected: selectedCategories['Shopping'] ?? false,
                            onTap: () {},
                          ),
                          const SizedBox(height: 20), // Padding extra inferior al scrollear
                        ],
                      ),
                    ),

                    // --- BOTÓN DE ACCIÓN INFERIOR ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        _buildGlassButtonFormatoImagen(
                          text: 'Lock these in →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: () {
                            // Guardar selección y proceder al Screen 16
                            _nextPage();
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- WIDGET AUXILIAR PRIVADO PARA CADA FILA DE CATEGORÍA ---
Widget _buildCategoryRow({
  required String title,
  required int appCount,
  required IconData icon,
  required bool isSelected,
  bool showAllBadge = false,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isSelected ? 0.08 : 0.05),
            Colors.white.withOpacity(isSelected ? 0.04 : 0.02),
          ],
        ),
      ),
      child: Row(
        children: [
          // Checkbox circular exterior estilizado
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 16,
                  )
                : null,
          ),
          
          const SizedBox(width: 14),
          
          // Icono representativo de la categoría en contenedor suave
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 14),
          
          // Textos de Categoría y cantidad de Apps detectadas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$appCount apps',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Badge opcional de granularidad "All" + Flecha de despliegue
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAllBadge)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    'All',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  // ==========================================
  // PANTALLA 16: A nudge, never noise
  // ==========================================
  double _nudgeMinutes = 30;
Widget _buildScreen16() {
  final controller = _currentVideoController;

  // Estado local para el slider (puedes moverlo a tu manejador de estados o State)
  // 30 minutos es el valor por defecto de la imagen
  double currentNudgeValue = 30.0; 

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO (Fondo de bosque/vegetación según la secuencia) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), // Mantiene la consistencia de contraste
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ CONTROLADA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso general de líneas
                    const SizedBox(height: 35),

                    // --- ENCABEZADO Y TEXTOS ---
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.left,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'A nudge, never noise.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Here's exactly what ZŌN will send. Nothing else — no streak-or-die spam.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- VISTAS PREVIAS DE NOTIFICACIONES (Simuladas estilo iOS/Glass) ---
                    _buildNotificationPreview(
                      title: 'Your habitat is waiting.',
                      body: "It's 9:00 — your usual focus window. Start a session?",
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildNotificationPreview(
                      title: "You've spent 32 min in Instagram.",
                      body: 'Remember your mission — want to lock it down and start a session?',
                    ),

                    const Spacer(),

                    // --- SECCIÓN INTERACTIVA: SLIDER DE TIEMPO (Nudge interval) ---
                    Text(
                      "Nudge me after I've been in a blocked app for:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    // Indicador dinámico de minutos en fuente monoespaciada/limpia
                    StatefulBuilder(
                      builder: (context, setStateInternal) {
                        return Column(
                          children: [
                            Text(
                              '${currentNudgeValue.round()} min',
                              style: const TextStyle(
                                fontFamily: 'Courier', // Estilo técnico/mono de la imagen
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Slider personalizado con track grueso y thumb hueso/crema
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 12,
                                activeTrackColor: Colors.white.withOpacity(0.15),
                                inactiveTrackColor: Colors.white.withOpacity(0.08),
                                thumbColor: const Color(0xFFEAE6DF), // Color hueso/crema del diseño
                                overlayColor: Colors.white.withOpacity(0.1),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                trackShape: const RoundedRectSliderTrackShape(),
                              ),
                              child: Slider(
                                value: currentNudgeValue,
                                min: 15,
                                max: 120, // 2 horas max
                                onChanged: (value) {
                                  setStateInternal(() {
                                    currentNudgeValue = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Etiquetas inferiores del Slider (15 min y 2 hr)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15 min', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                          Text('2 hr', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Leyenda del reloj de intervalo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: Colors.white.withOpacity(0.3), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'You pick the interval — change it anytime. Never a nag.',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // --- BLOQUE INFERIOR DE ACCIÓN ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGlassButtonFormatoImagen(
                          text: 'Allow notifications →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: () {
                           _nextPage();
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _nextPage,
                          child: Text(
                            'Not now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- WIDGET AUXILIAR PARA RENDERIZAR LAS NOTIFICACIONES ESTILO BANNER ---
Widget _buildNotificationPreview({
  required String title,
  required String body,
}) {
  return Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.06),
          Colors.white.withOpacity(0.02),
        ],
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de la App ZŌN en color verde esmeralda suave
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0E241B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: const Icon(
            Icons.shield_outlined, 
            color: Color(0xFF2ECC71), 
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        // Contenido del Banner
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Z Ō N',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    'now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildMockNotification({required String title, required String subtitle}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16), color: const Color(0xFF1A1A1E).withOpacity(0.7),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.shield, color: Colors.white, size: 16)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ZŌN • now', style: TextStyle(color: ZonColors.bone40, fontSize: 11)),
                  Text(title, style: const TextStyle(color: ZonColors.bone, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: ZonColors.bone60, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PANTALLA 17: How did you find us?
  // ==========================================
  final List<String> _sources = ['TikTok', 'Instagram', 'App Store', 'Reddit', 'YouTube'];
  int _selectedSourceIdx = 2;

Widget _buildScreen17() {
  final controller = _currentVideoController;

  // Estado local para rastrear qué opción ha seleccionado el usuario
  String selectedSource = "";

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // --- CAPA 1: VIDEO DE FONDO (Consistencia de secuencia) ---
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), 
                    BlendMode.darken,
                  ),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: Container(color: Colors.black),
                ),
        ),

        // --- CAPA 2: INTERFAZ DE ENCUESTA ---
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Margen superior para la barra de progreso de líneas
                    const SizedBox(height: 35),

                    // --- ENCABEZADO Y TÍTULO ---
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.left,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 34,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'How did you find us?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Last thing — it helps us reach more people who need this.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- LISTADO DE OPCIONES (CON SCROLL) ---
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setStateInternal) {
                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildSurveyOption(
                                label: 'TikTok',
                                icon: Icons.music_note_rounded, // Representando TikTok
                                isSelected: selectedSource == 'TikTok',
                                onTap: () => setStateInternal(() => selectedSource = 'TikTok'),
                              ),
                              const SizedBox(height: 10),
                              _buildSurveyOption(
                                label: 'Instagram',
                                icon: Icons.camera_alt_outlined,
                                isSelected: selectedSource == 'Instagram',
                                onTap: () => setStateInternal(() => selectedSource = 'Instagram'),
                              ),
                              const SizedBox(height: 10),
                              _buildSurveyOption(
                                label: 'App Store',
                                icon: Icons.apple,
                                isSelected: selectedSource == 'App Store',
                                onTap: () => setStateInternal(() => selectedSource = 'App Store'),
                              ),
                              const SizedBox(height: 10),
                              _buildSurveyOption(
                                label: 'A friend or family',
                                icon: Icons.people_outline_rounded,
                                isSelected: selectedSource == 'Friend',
                                onTap: () => setStateInternal(() => selectedSource = 'Friend'),
                              ),
                              const SizedBox(height: 10),
                              _buildSurveyOption(
                                label: 'Reddit',
                                icon: Icons.forum_outlined,
                                isSelected: selectedSource == 'Reddit',
                                onTap: () => setStateInternal(() => selectedSource = 'Reddit'),
                              ),
                              const SizedBox(height: 10),
                              _buildSurveyOption(
                                label: 'YouTube',
                                icon: Icons.play_circle_outline_rounded,
                                isSelected: selectedSource == 'YouTube',
                                onTap: () => setStateInternal(() => selectedSource = 'YouTube'),
                              ),
                              const SizedBox(height: 10),
                              _buildSurveyOption(
                                label: 'Somewhere else',
                                icon: Icons.more_horiz_rounded,
                                isSelected: selectedSource == 'Other',
                                onTap: () => setStateInternal(() => selectedSource = 'Other'),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),

                    // --- BOTÓN DE CIERRE DE SECUENCIA ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        _buildGlassButtonFormatoImagen(
                          text: 'Continue →',
                          icon: Icons.arrow_forward,
                          showIcon: false,
                          onTap: () {
                            // Finalizar flujo y navegar al Home o siguiente paso
                          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false, // Elimina todas las pantallas previas del stack
        );
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// --- WIDGET AUXILIAR PARA LAS FILAS DE LA ENCUESTA ---
Widget _buildSurveyOption({
  required String label,
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isSelected ? 0.08 : 0.05),
            Colors.white.withOpacity(isSelected ? 0.04 : 0.02),
          ],
        ),
      ),
      child: Row(
        children: [
          // Icono de la plataforma/fuente
          Icon(
            icon,
            color: Colors.white.withOpacity(isSelected ? 0.9 : 0.5),
            size: 22,
          ),
          const SizedBox(width: 16),
          // Etiqueta de texto
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.8),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          // Círculo de selección estilo Radio (derecha)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}



}

class LocalTransitionVideoWidget extends StatefulWidget {
  final String videoPath;
  final double opacity; 

  const LocalTransitionVideoWidget({
    super.key, 
    required this.videoPath,
    this.opacity = 1.0, 
  });

  @override
  State<LocalTransitionVideoWidget> createState() => _LocalTransitionVideoWidgetState();
}

class _LocalTransitionVideoWidgetState extends State<LocalTransitionVideoWidget> {
  VideoPlayerController? _localVideoController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _localVideoController = VideoPlayerController.asset(
      widget.videoPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _localVideoController?.setLooping(true);
          _localVideoController?.setVolume(0.0); 
          _localVideoController?.play();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _localVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.white.withOpacity(0.03),
        child: const Center(
          child: Icon(Icons.videocam_off_outlined, color: ZonColors.bone, size: 32),
        ),
      );
    }

    if (_localVideoController != null && _localVideoController!.value.isInitialized) {
      return Opacity(
        opacity: widget.opacity,
        // Usamos el AspectRatio real y exacto del propio archivo de video para evitar deformaciones u omisiones
        child: AspectRatio(
          aspectRatio: _localVideoController!.value.aspectRatio,
          child: FittedBox(
            fit: BoxFit.contain, // Muestra absolutamente todo el video dentro del recuadro sin cortar nada
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _localVideoController!.value.size.width,
              height: _localVideoController!.value.size.height,
              child: VideoPlayer(_localVideoController!),
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.white.withOpacity(0.02),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(ZonColors.gold),
            ),
          ),
        ),
      );
    }
  }
}
/*import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Recuerda agregar video_player: ^2.8.1 en pubspec.yaml
import 'package:flutter/foundation.dart';
// --- PALETA DE COLORES ZŌN (MANTENIENDO TU ESTÉTICA) ---
class ZonColors {
  static const Color obsidian = Color(0xFF06141E);
  static const Color obsidianBg = Color(0xFF0A0A0C);
  static const Color bone = Color(0xFFF2EDE0);
  static const Color gold = Color(0xFFF2A938);
  static const Color flare = Color(0xFFFF5A4D);
  static Color bone60 = const Color(0xFFF2EDE0).withOpacity(0.60);
  static Color bone40 = const Color(0xFFF2EDE0).withOpacity(0.40);
  static Color biomeGlow = const Color(0xFF3C6E5A).withOpacity(0.25);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // SOLUCIÓN DEFINITIVA: Interceptamos debugPrint para silenciar la basura de la GPU de Android
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && (message.contains('gralloc4') || message.contains('BufferPool'))) {
      return; // Ignora los frames del video en la consola
    }
    // Deja pasar tus prints normales
    debugPrintThrottled(message, wrapWidth: wrapWidth);
  };

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ZonOnboardingScreen(),
  ));
}
// --- WIDGET BASE MODIFICADO: INTEGRA EL VIDEO MP4 DE FONDO EN LUGAR DE LA IMAGEN ---
class ZonBaseLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final int currentStep;

  const ZonBaseLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.currentStep = 13,
  });

  @override
  State<ZonBaseLayout> createState() => _ZonBaseLayoutState();
}

class _ZonBaseLayoutState extends State<ZonBaseLayout> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/assets-s12a-bg.mp4');
    // NOTA: Cambia a VideoPlayerController.asset('assets/tu_video.mp4') si lo tienes local.
    /*_videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    );*/

    _videoController.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZonColors.obsidianBg,
      body: Stack(
        children: [
          // 1. Video MP4 en bucle con filtro de oscurecimiento (Sustituye a Image.network)
          Positioned.fill(
            child: _isInitialized
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.7),
                      BlendMode.darken,
                    ),
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
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
          // 2. Resplandor Verde inferior (Biome Glow)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, 1.2),
                  radius: 1.0,
                  colors: [ZonColors.biomeGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          // 3. UI Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar: Back + Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ZonColors.bone40),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: ZonColors.bone),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(child: _buildProgressBar()),
                    ],
                  ),
                ),
                // Textos de Cabecera
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'Serif', // Simula Instrument Serif
                          fontStyle: FontStyle.italic,
                          fontSize: 36,
                          color: ZonColors.bone,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle,
                        style: TextStyle(fontSize: 15, color: ZonColors.bone60, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(18, (index) {
        bool isDone = index < widget.currentStep;
        bool isCurrent = index == widget.currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 3,
            decoration: BoxDecoration(
              color: isCurrent ? ZonColors.bone : (isDone ? ZonColors.bone.withOpacity(0.3) : Colors.white10),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ==========================================
// PANTALLA 1: ONBOARDING (LA DE LA IMAGEN)
// ==========================================
class ZonOnboardingScreen extends StatelessWidget {
  const ZonOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZonBaseLayout(
      title: "Create your account",
      subtitle: "So your habitat stays yours — on any device.",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          children: [
            const Spacer(),
            // Botón Principal: Use phone or email
            _buildPrimaryButton(
              label: "Use phone or email",
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZonRegisterScreen())),
            ),
            const SizedBox(height: 15),
            const Text("or", style: TextStyle(color: Colors.white24, fontSize: 14)),
            const SizedBox(height: 15),
            // Botones Sociales Glass
            _buildGlassButton(label: "Continue with Apple", icon: Icons.apple),
            const SizedBox(height: 12),
            _buildGlassButton(label: "Continue with Google", icon: Icons.g_mobiledata),
            const SizedBox(height: 12),
            _buildGlassButton(label: "Continue with Facebook", icon: Icons.facebook),
            const SizedBox(height: 20),
            // Términos
            Text(
              "By continuing you agree to our Terms of Service and acknowledge our Privacy Policy.",
              textAlign: TextAlign.center,
              style: TextStyle(color: ZonColors.bone40, fontSize: 11, height: 1.5),
            ),
            const Spacer(),
            // Link Login al final
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZonLoginScreen())),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: ZonColors.bone60, fontSize: 15),
                    children: const [
                      TextSpan(text: "Log In", style: TextStyle(color: ZonColors.gold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C222D),
          foregroundColor: ZonColors.bone,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }

  Widget _buildGlassButton({required String label, required IconData icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ZonColors.bone, size: 24),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: ZonColors.bone, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA 2: LOGIN CON EMAIL
// ==========================================
class ZonLoginScreen extends StatelessWidget {
  const ZonLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZonBaseLayout(
      title: "Welcome Back",
      subtitle: "Enter your email to resume your sessions.",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildGlassInput(hint: "Email address", icon: Icons.email_outlined),
            const SizedBox(height: 15),
            _buildGlassInput(hint: "Password", icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 30),
            _buildActionButton(label: "Log In", color: ZonColors.gold),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA 3: REGISTRO CON EMAIL
// ==========================================
class ZonRegisterScreen extends StatelessWidget {
  const ZonRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ZonBaseLayout(
      title: "Setup Account",
      subtitle: "Create a new habitat tied to your person.",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildGlassInput(hint: "Email address", icon: Icons.email_outlined),
            const SizedBox(height: 15),
            _buildGlassInput(hint: "Set Password", icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 30),
            _buildActionButton(label: "Create Account", color: ZonColors.flare),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// --- HELPERS PARA INPUTS Y BOTONES ---

Widget _buildGlassInput({required String hint, required IconData icon, bool isPassword = false}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
        child: TextField(
          obscureText: isPassword,
          style: const TextStyle(color: ZonColors.bone),
          decoration: InputDecoration(
            icon: Icon(icon, color: ZonColors.bone40, size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: ZonColors.bone40, fontSize: 14),
            border: InputBorder.none,
          ),
        ),
      ),
    ),
  );
}

Widget _buildActionButton({required String label, required Color color}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
    ),
    child: Center(child: Text(label, style: const TextStyle(color: ZonColors.obsidian, fontWeight: FontWeight.bold, fontSize: 16))),
  );
}*/