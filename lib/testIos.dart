import 'package:app_blocker/app_blocker.dart';
import 'package:flutter/material.dart';

class ScreenTimeSetup extends StatefulWidget {
  const ScreenTimeSetup({super.key});

  @override
  State<ScreenTimeSetup> createState() => _ScreenTimeSetupState();
}

class _ScreenTimeSetupState extends State<ScreenTimeSetup> {
  final blocker = AppBlocker.instance;
  BlockerPermissionStatus _permissionStatus = BlockerPermissionStatus.denied;
  List<String> _selectedApps = [];

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
    _listenToBlockEvents();
  }

  /// Verifica el estado actual del permiso de Screen Time
  Future<void> _checkAuthorization() async {
    final status = await blocker.requestPermission();
    setState(() {
      _permissionStatus = status;
    });
    
    print('Estado del permiso: $status');
  }

  /// Escucha eventos de bloqueo/desbloqueo
  void _listenToBlockEvents() {
    blocker.onBlockEvent.listen((event) {
      print('Evento: ${event.type} - ${event.packageName}');
    });
  }

  /// Verifica si el permiso fue concedido
  bool get isAuthorized {
    return _permissionStatus == BlockerPermissionStatus.granted;
  }

  /// Abre el selector nativo de apps de iOS (FamilyActivityPicker)
  Future<void> _openAppPicker() async {
    if (!isAuthorized) {
      await _checkAuthorization();
      return;
    }

    await blocker.getApps(); 
    final blocked = await blocker.getBlockedApps();
    setState(() {
      _selectedApps = blocked;
    });
  }

  /// Activa el bloqueo de las apps seleccionadas
  Future<void> _startBlocking() async {
    if (_selectedApps.isEmpty) {
      await blocker.blockAll();
    } else {
      await blocker.blockApps(_selectedApps);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apps bloqueadas en iOS. Ve a Ajustes → Tiempo en Uso para gestionar.')),
      );
    }
  }

  /// Desactiva el bloqueo de todas las apps
  Future<void> _stopBlocking() async {
    await blocker.unblockAll();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bloqueo desactivado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Apps en iOS')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!isAuthorized) ...[
              ElevatedButton(
                onPressed: _checkAuthorization,
                child: const Text('Autorizar Screen Time'),
              ),
              const SizedBox(height: 16),
              Text(
                _permissionStatus == BlockerPermissionStatus.denied
                    ? 'Permiso denegado. Ve a Ajustes → Tiempo en Uso para activarlo manualmente.'
                    : _permissionStatus == BlockerPermissionStatus.restricted
                        ? 'El acceso está restringido por políticas del dispositivo.'
                        : 'Presiona el botón para solicitar acceso a Screen Time.',
                textAlign: TextAlign.center,
              ),
            ],
            if (isAuthorized) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text('Permiso concedido para gestionar apps.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openAppPicker,
                icon: const Icon(Icons.apps),
                label: const Text('Seleccionar apps a bloquear'),
              ),
              const SizedBox(height: 10),
              if (_selectedApps.isNotEmpty)
                Text('Apps seleccionadas: ${_selectedApps.length}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startBlocking,
                    icon: const Icon(Icons.lock),
                    label: const Text('Activar Bloqueo'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  ElevatedButton.icon(
                    onPressed: _stopBlocking,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Desactivar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}