import Cocoa

public protocol MonitorScreen {
    var name: String { get }
}

struct ConnectedMonitorScreen: MonitorScreen {
    let screen: NSScreen

    var name: String {
        screen.localizedName
    }
}

struct SavedMonitorScreen: MonitorScreen {
    let name: String
}

protocol MonitorScreenResolver {
    func allScreens() -> [NSScreen]
    func connectedMonitors() -> [any MonitorScreen]
    func resolveScreen(for monitor: any MonitorScreen) -> NSScreen?
}

class MonitorScreenResolverImpl: MonitorScreenResolver {
    func allScreens() -> [NSScreen] {
        NSScreen.screens
    }

    func connectedMonitors() -> [any MonitorScreen] {
        allScreens().map { screen in
            ConnectedMonitorScreen(screen: screen)
        }
    }

    func resolveScreen(for monitor: any MonitorScreen) -> NSScreen? {
        if let connectedMonitor = monitor as? ConnectedMonitorScreen {
            if let screen = allScreens().first(where: { $0.deviceIdentifier == connectedMonitor.screen.deviceIdentifier }) {
                return screen
            }
        }

        return allScreens().first(where: { $0.localizedName == monitor.name })
    }
}

public enum WallpaperDisplayTarget {
    case sameOnAllMonitors
    case specificMonitor(screen: any MonitorScreen)
}
