import AppKit
import Injectable

protocol WallpaperWindowService {
    func display(display: WallpaperKind)
    func hide()
}

class WallpaperWindowServiceImpl: WallpaperWindowService {
    private var windowControllerList: [NSWindowController] = []
    private let wallpaperHistoryService: WallpaperHistoryService
    private let notificationManager: NotificationManager
    
    init(injector: Injectable) {
        self.notificationManager = injector.build()
        self.wallpaperHistoryService = injector.build()
        observeScreenParam()
    }
    
    func display(display: WallpaperKind) {
        windowControllerList.forEach { $0.close() }
        windowControllerList = []
        
        NSScreen.screens.forEach { [weak self] screen in
            let windowController = buildWallpaperWindow(screen: screen)
            self?.windowControllerList.append(windowController)
            windowController.showWindow(nil, display: display)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                windowController.fitFrame(for: screen)
            }
        }
        
        // Set the cached thumbnail as the wallpaper
        // FIXME: Bug in macOS Ventura (13.2.1)  prevents setting the wallpaper on others than the main monitor! See https://cdn.discordapp.com/attachments/1061735833889149049/1084525937468645437/Bildschirmaufnahme_2023-03-12_um_18.17.31.mov
        // FIXME: The menu bar does not seem to have a color similiar to the background, have a look at this: https://cdn.discordapp.com/attachments/1061735833889149049/1084526654287777882/Bildschirmfoto_2023-03-12_um_18.21.34.png
        if let _ = try? SystemWallpaperServiceImpl().backupWallpapers() {
            if let newWallpaper = ApplicationFileManagerImpl().getFile(fileName: "latest.png", dir: .latestThumb) {
                NSScreen.screens.forEach { screen in
                    if let _ = try? NSWorkspace.shared.setDesktopImageURL(newWallpaper, for: screen) {} else {
                        print("Failed to set wallpaper for \(screen)")
                    }
                }
                NSStatusBar.system.removeStatusItem(NSStatusBar.system.statusItem(withLength: 200))
            }
        } else {
            print("Failed to back up wallpapers! Refusing to set up images that would line up the menubar!")
        }
    }
    
    func hide() {
        windowControllerList.forEach { $0.close() }
        windowControllerList = []
    }
    
    private func buildWallpaperWindow(screen: NSScreen) -> WallMovieWindowController {
        let coordinator = WallMovieCoordinator(injector: Injector(container: WallMovieContainerBuilder.build(parent: Injector.shared.container)), screenFrame: screen.frame)
        let windowController = WallMovieWindowController(windowNibName: .windowController.wallMovie)
        windowController.contentViewController = coordinator.create()
        return windowController
    }
    
    private func observeScreenParam() {
        notificationManager.observe(name: NSApplication.didChangeScreenParametersNotification) { [weak self] _ in
            guard let latestWallpaper = self?.wallpaperHistoryService.fetchLatestWallpaper() else { return }
            self?.display(display: latestWallpaper)
        }
    }
}
