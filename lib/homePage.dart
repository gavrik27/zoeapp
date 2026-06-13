import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:zoeapp/testIos.dart';

import 'focusSession.dart';

class ZonColors {
  static const Color bone = Color(0xFFEAE6DF);
  static const Color gold = Color(0xFFD4AF37);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoController;
  int _currentNavIndex = 0; // Índice para la barra de navegación inferior
  final PageController _cardsPageController = PageController();
  int _currentCardIndex = 0;
  static const platform = MethodChannel('app.intozon.zon/kiosk');
  
  bool _overlayGranted = false;
  bool _kioskActiveOnNative = false;
  @override
  void initState() {
    super.initState();
    
    // Inicializa el video de fondo que vayas a colocar en la Home
    _videoController = VideoPlayerController.asset('assets/assets-home-rainforest-day.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
        setState(() {});
      });
      _checkStatus();
      
  }
 Future<void> _checkStatus() async {
    final overlayStatus = await Permission.systemAlertWindow.status;
    bool nativeKioskState = false;
    try {
      nativeKioskState = await platform.invokeMethod('isKioskActive');
    } catch (e) {
      print(e);
    }

    setState(() {
      _overlayGranted = overlayStatus.isGranted;
      _kioskActiveOnNative = nativeKioskState;
    });

    // Si ya todo está listo y el modo quedó activo de antes (o tras reiniciar)
    if (_overlayGranted && _kioskActiveOnNative) {
      _irAPantallaEstudio();
    }
  }


  Future<void> _requestOverlay() async {
    final status = await Permission.systemAlertWindow.request();
    setState(() {
      _overlayGranted = status.isGranted;
    });
  }

 Future<void> _openAccessibility() async {
  try {
    // Intentamos abrir la lista de accesibilidad nativa primero
    await platform.invokeMethod('openAccessibilitySettings');
  } catch (e) {
    // Si falla o se bloquea, forzamos la apertura directa del servicio específico
    final AndroidIntent intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    await intent.launch();
  }
}
Future<void> _irAPantallaEstudio2() async {
 
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreenTimeSetup()),
    );
}
Future<void> _irAPantallaEstudio() async {
    // Verificar overlay nuevamente
    final overlayStatus = await Permission.systemAlertWindow.status;
    if (!overlayStatus.isGranted) {
        await Permission.systemAlertWindow.request();
        return;
    }
    
    try {
        await platform.invokeMethod('setKioskActive', {'active': true});
    } catch (e) {
        print(e);
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FocusSessionPage()),
    );
}
  @override
  void dispose() {
    _videoController.dispose();
    _cardsPageController.dispose();
    super.dispose();
  }

  // --- COMPONENTES AUXILIARES DE DISEÑO (Declarados como métodos de la clase) ---

  Widget _buildHeaderCircleButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
    );
  }

  Widget _buildDayIndicator(String letter, bool isToday) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            letter,
            style: TextStyle(
              color: isToday ? Colors.white : Colors.white.withOpacity(0.25),
              fontSize: 13,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          // El punto sutil indicador debajo del día actual
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday ? const Color(0xFFFFA500) : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String val, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.12),
    );
  }

  Widget _buildHorizontalCard({
    required IconData icon,
    required String boldText,
    required String normalText,
    required String footerText,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2ECC71), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                    children: [
                      const TextSpan(text: 'The time you scrolled this week is '),
                      TextSpan(
                        text: boldText,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: normalText,
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                Text(
                  footerText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? ZonColors.gold : Colors.white.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
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
                      Colors.black.withOpacity(0.4), // Opacidad sutil para apreciar el paisaje
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

          // --- CAPA 2: INTERFAZ DE USUARIO ---
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado Superior (Greeting + Íconos de acción rápido)
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good evening.',
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SUN · JUN 2',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      // Fila de botones redondos superiores y el Badge de Racha/Streak
                      Row(
                        children: [
                          _buildHeaderCircleButton(Icons.wb_sunny_outlined),
                          const SizedBox(width: 10),
                          _buildHeaderCircleButton(Icons.eco_outlined),
                          const SizedBox(width: 10),
                          // Badge de Streak con llama dorada
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.local_fire_department, color: Color(0xFFFFA500), size: 18),
                                SizedBox(width: 4),
                                Text(
                                  '12',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- CALENDARIO SEMANAL MINI (M T W T F S S) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildDayIndicator('M', false),
                      _buildDayIndicator('T', false),
                      _buildDayIndicator('W', false),
                      _buildDayIndicator('T', false),
                      _buildDayIndicator('F', false),
                      _buildDayIndicator('S', false),
                      _buildDayIndicator('S', true), // Domingo activo
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // --- SUBTITULO CENTRAL DE UBICACIÓN ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, color: Colors.white.withOpacity(0.6), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'YOUR AMAZON · RAINFOREST',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- SECCIÓN DE TELEMETRÍA/MÉTRICAS DEL DÍA ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricItem('2h 15m', 'focus'),
                      _buildVerticalDivider(),
                      _buildMetricItem('3h 42m', 'screen'),
                      _buildVerticalDivider(),
                      _buildMetricItem('12-day', 'streak'),
                    ],
                  ),
                ),

              //  const Spacer(flex: 3),


Column(
  mainAxisSize: MainAxisSize.min, // Evita que la columna se expanda verticalmente por completo
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    // --- Permiso 1: Superposición ---
    Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        dense: true, // Reduce fuentes y espacios generales
        visualDensity: VisualDensity.compact, // Compactación estructural de Flutter
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Padding ultra controlado
        leading: Icon(
          _overlayGranted ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: _overlayGranted ? const Color(0xFF2ECC71) : Colors.redAccent,
          size: 20,
        ),
        title: const Text(
          "Mostrar sobre otras Apps",
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Necesario para dibujar el bloqueo de pantalla.",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
        trailing: SizedBox(
          height: 28, // Altura ultra reducida para el botón
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Colors.white.withOpacity(0.12),
              disabledBackgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _overlayGranted ? null : _requestOverlay,
            child: Text(
              "Dar",
              style: TextStyle(color: _overlayGranted ? Colors.white30 : Colors.white, fontSize: 11),
            ),
          ),
        ),
      ),
    ),

    // --- Permiso 2: Accesibilidad ---
    Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const Icon(Icons.accessibility_new_rounded, color: Colors.orangeAccent, size: 20),
        title: const Text(
          "Servicio de Accesibilidad",
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Busca tu app en la lista y actívala.",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
        trailing: SizedBox(
          height: 28,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Colors.white.withOpacity(0.12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _openAccessibility,
            child: const Text("Ir", style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
      ),
    ),

    const SizedBox(height: 1),

    // --- Botón de Acción Principal REDONDO (Icono ON) ---
   // --- Botón de Acción Principal REDONDO (Icono ON) ---


Row(
 
  children: [
     const SizedBox(width: 20),
Center(
  child: Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withOpacity(_overlayGranted ? 0.25 : 0.4),
        width: 1.5,
      ),
      color: _overlayGranted ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
      boxShadow: _overlayGranted ? [
        BoxShadow(
          color: Colors.white.withOpacity(0.02),
          blurRadius: 15,
          spreadRadius: 2,
        )
      ] : null,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: _overlayGranted ? _irAPantallaEstudio : null,
        child: Center(
          child: Icon(
            Icons.power_settings_new_rounded,
            size: 25,
            color: _overlayGranted ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    ),
  ),
),
  const SizedBox(width: 200),
Center(
  child: Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withOpacity(_overlayGranted ? 0.25 : 0.4),
        width: 1.5,
      ),
      color:  Colors.red.withOpacity(0.02),
      boxShadow: _overlayGranted ? [
        BoxShadow(
          color: Colors.white.withOpacity(0.02),
          blurRadius: 15,
          spreadRadius: 2,
        )
      ] : null,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        onTap: _irAPantallaEstudio2 ,
        child: Center(
          child: Icon(
            Icons.power_settings_new_rounded,
            size: 25,
            color: Colors.red ,
          ),
        ),
      ),
    ),
  ),
),
    const SizedBox(width: 20),],
),
 
  ],
),

         
         
                // --- SECCIÓN "DID YOU KNOW?" (Carrusel Horizontal) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'DID YOU KNOW?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 135,
                  child: PageView(
                    controller: _cardsPageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentCardIndex = index;
                      });
                    },
                    children: [
                      _buildHorizontalCard(
                        icon: Icons.menu_book_rounded,
                        boldText: '150 pages ',
                        normalText: 'of a book you\'d actually finish.',
                        footerText: '4h 12m on social · this week',
                      ),
                      _buildHorizontalCard(
                        icon: Icons.directions_run_rounded,
                        boldText: 'The time you scrolled ',
                        normalText: 'this week could be spent training.',
                        footerText: '21m remaining today',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Indicador de puntos (Dots) para las tarjetas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentCardIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // --- TÍTULO SECCIÓN DIARIA INFERIOR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'DAILY',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Vista previa recortada al fondo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // --- BARRA DE NAVEGACIÓN INFERIOR (CUSTOM GLASS) ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF070E14).withOpacity(0.92), 
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.hourglass_empty_rounded, 'ZŌN'),
                _buildNavItem(1, Icons.eco_outlined, 'Habitat'),
                _buildNavItem(2, Icons.king_bed_outlined, 'Sleep'),
                _buildNavItem(3, Icons.emoji_events_outlined, 'Ranks'),
                _buildNavItem(4, Icons.person_outline_rounded, 'You'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}