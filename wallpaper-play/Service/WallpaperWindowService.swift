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
        let oldWallpapers = [Int: URL]()
        let oldWallpapersBackup = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appending(path: "wallpapers_backup.json"))
        
        NSScreen.screens.forEach { [weak self] screen in
            let windowController = buildWallpaperWindow(screen: screen)
            self?.windowControllerList.append(windowController)
            windowController.showWindow(nil, display: display)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSWorkspace.shared.setDesktopImageURL(WallMovieThumbnailGenerator.generate(for: display), for: screen)
                windowController.fitFrame(for: screen)
            }
        }
        
        if let _ = try? JSONEncoder().encode(oldWallpapers).write(to: oldWallpapersBackup) {
            let newWallpaper = WallMovieThumbnailGenerator.generate(for: display)!
            NSScreen.screens.forEach { oldWallpapers.updateValue(NSWorkspace.shared.setDesktopImageURL(newWallpaper, for: screen)!, forKey: screen.hashValue) }
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
