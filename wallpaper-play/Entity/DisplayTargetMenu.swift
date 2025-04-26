import Cocoa

enum DisplayTargetMenu {
    case allMonitors
    case screen(NSScreen)

    var title: String {
        switch self {
        case .allMonitors:
            return "All Monitors"
        case .screen(let screen):
            return screen.localizedName
        }
    }
}
