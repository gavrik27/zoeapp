import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'focusSession.dart';
import 'homePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Estudio',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
    );
  }
}

// ----------------------------------------------------------------------
// PANTALLA 1: CONTROL Y SOLICITUD DE PERMISOS
// ----------------------------------------------------------------------
class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({Key? key}) : super(key: key);

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  static const platform = MethodChannel('app.intozon.zon/kiosk');
  
  bool _overlayGranted = false;
  bool _kioskActiveOnNative = false;

  @override
  void initState() {
    super.initState();
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
        MaterialPageRoute(builder: (context) => const StudyScreen()),
    );
}
  /*void _irAPantallaEstudio() async {
    try {
      // Indicamos al servicio nativo que empiece a bloquear salidas
      await platform.invokeMethod('setKioskActive', {'active': true});
    } catch (e) {
      print(e);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StudyScreen()),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración de Bloqueo")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text(
              "Para evitar distracciones, concede los siguientes accesos. Al iniciar el modo estudio, no podrás salir del entorno.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            
            // Permiso 1: Superposición
            ListTile(
              leading: Icon(
                _overlayGranted ? Icons.check_circle : Icons.cancel,
                color: _overlayGranted ? Colors.green : Colors.red,
              ),
              title: const Text("Mostrar sobre otras Apps"),
              subtitle: const Text("Necesario para dibujar el bloqueo de pantalla."),
              trailing: ElevatedButton(
                onPressed: _overlayGranted ? null : _requestOverlay,
                child: const Text("Dar"),
              ),
            ),
            const Divider(),

            // Permiso 2: Accesibilidad
            ListTile(
              leading: const Icon(Icons.accessibility_new, color: Colors.orange),
              title: const Text("Servicio de Accesibilidad"),
              subtitle: const Text("Busca tu app en la lista y actívala."),
              trailing: ElevatedButton(
                onPressed: _openAccessibility,
                child: const Text("Ir"),
              ),
            ),
            const SizedBox(height: 50),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.indigo,
              ),
              onPressed: _overlayGranted ? _irAPantallaEstudio : null,
              child: const Text("EMPEZAR A ESTUDIAR NOW", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// PANTALLA 2: MODO ESTUDIO BLOQUEADO COMPLETAMENTE
// ----------------------------------------------------------------------
class StudyScreen extends StatefulWidget {
  const StudyScreen({Key? key}) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  static const platform = MethodChannel('app.intozon.zon/kiosk');

  @override
  void initState() {
    super.initState();
    // Ocultar barras del sistema operativo para dificultar despliegues accidentales
     // Ocultar TODO (barra de navegación y barra de estado)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
    ));
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
      MaterialPageRoute(builder: (context) => const PermissionCheckScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope (o WillPopScope) intercepta y anula el botón de atrás nativo de Flutter
    return PopScope(
      canPop: false, // Bloquea totalmente el gesto/botón de atrás físico
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Estilo enfocado oscuro
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 100, color: Colors.cyanAccent),
                const SizedBox(height: 30),
                const Text(
                  "ENTORNO DE ESTUDIO ACTIVO",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Tu teléfono está bloqueado para evitar procrastinación. Todo el sistema está restringido a esta pantalla.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 60),
                
                // Único botón capaz de liberar el dispositivo
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(250, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _desactivarYSalir,
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text(
                    "SALIR Y DESBLOQUEAR",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';

import 'loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ZonOnboardingScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/