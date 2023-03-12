import Foundation
import AppKit

protocol SystemWallpaperService {
    //func setWallpaper(_ url: URL) throws
    func backupWallpapers() throws
    func restoreWallpaper() throws
}

class SystemWallpaperServiceImpl: SystemWallpaperService {
    func setWallpaper(_ url: URL) throws {
        try NSWorkspace.shared.setDesktopImageURL(url, for: NSScreen.main!)
    }
    
    func backupWallpapers() throws {
        var wallpapers = [String]()
        NSScreen.screens.forEach { screen in
            if let url = NSWorkspace.shared.desktopImageURL(for: screen) {
                guard url != ApplicationFileManagerImpl().getDirectory(.latestThumb)!.appendingPathComponent("latest.png") else { return } // do not backup the saved thumbnail
                wallpapers.append(url.path)
            }
        }
        
        if !wallpapers.isEmpty {
            try JSONSerialization.data(withJSONObject: wallpapers).write(to: ApplicationFileManagerImpl().getDirectory(.latestThumb)!.appendingPathComponent("wallpaper_backup.json"))
        }
        
    }
    
    func restoreWallpaper() throws {
        let wallpapers = try JSONSerialization.jsonObject(with: Data(contentsOf: ApplicationFileManagerImpl().getDirectory(.latestThumb)!.appendingPathComponent("wallpaper_backup.json")), options: []) as! [String]
        for (idx, wallpaperPath) in wallpapers.enumerated() {
            if idx < NSScreen.screens.count-1 {
                try NSWorkspace.shared.setDesktopImageURL(URL(fileURLWithPath: wallpaperPath), for: NSScreen.screens[idx])
            }
        }
        NSStatusBar.system.removeStatusItem(NSStatusBar.system.statusItem(withLength: 200))
    }
}
