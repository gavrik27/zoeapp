import DeviceActivity
import ManagedSettings

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("✅ Bloqueo activado - Aplicando restricciones")
        
        // Aquí se aplican los bloqueos que tu app configuró
        // El paquete app_blocker maneja esto automáticamente
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("🔓 Bloqueo desactivado - Liberando restricciones")
        store.clearAllSettings()
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("⏰ Límite de tiempo alcanzado")
    }
}