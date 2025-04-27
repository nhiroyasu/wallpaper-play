import Cocoa

public enum WallpaperDisplayTarget {
    case sameOnAllMonitors
    case specificMonitor(screen: NSScreen)
}
