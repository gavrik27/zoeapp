import ManagedSettings
import FamilyControls
import DeviceActivity

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Esta es la pantalla que ve el usuario cuando intenta abrir una app bloqueada
        return ShieldConfiguration(
            backgroundColor: .black,
            icon: nil,
            title: .init(text: "🔒 Modo Estudio Activo", color: .white),
            subtitle: .init(text: "Esta aplicación está bloqueada durante tu tiempo de estudio", color: .lightGray),
            primaryButtonLabel: .init(text: "Salir del Modo", color: .white),
            primaryButtonBackgroundColor: .systemRed,
            secondaryButtonLabel: .init(text: "Solicitar tiempo extra", color: .white),
            secondaryButtonBackgroundColor: .systemBlue
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Pantalla cuando se bloquea una categoría completa
        return ShieldConfiguration(
            backgroundColor: .black,
            icon: nil,
            title: .init(text: "📱 Categoría Bloqueada", color: .white),
            subtitle: .init(text: "Las apps de esta categoría están bloqueadas en modo estudio", color: .lightGray),
            primaryButtonLabel: .init(text: "Ver Configuración", color: .white),
            primaryButtonBackgroundColor: .systemBlue
        )
    }
}