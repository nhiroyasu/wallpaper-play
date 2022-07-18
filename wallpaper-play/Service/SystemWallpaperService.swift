import Foundation
import AppKit

protocol SystemWallpaperService {
    func setWallpaper(_ url: URL) throws
}

class SystemWallpaperServiceImpl: SystemWallpaperService {
    func setWallpaper(_ url: URL) throws {
        try NSWorkspace.shared.setDesktopImageURL(url, for: NSScreen.main!)
    }
}
