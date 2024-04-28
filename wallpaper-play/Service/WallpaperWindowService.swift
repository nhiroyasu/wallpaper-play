import AppKit
import Injectable

protocol WallpaperWindowService {
    func display(display: WallpaperKind)
    func hide()
    func isVisibleWallpaperWindow() -> Bool
}

class WallpaperWindowServiceImpl: WallpaperWindowService {
    private var windowControllerList: [NSWindowController] = []
    private let wallpaperHistoryService: WallpaperHistoryService
    private let notificationManager: NotificationManager
    private let youTubeContentsService: YouTubeContentsService
    
    init(injector: Injectable) {
        self.notificationManager = injector.build()
        self.wallpaperHistoryService = injector.build()
        self.youTubeContentsService = injector.build()
        observeScreenParam()
    }
    
    func display(display: WallpaperKind) {
        windowControllerList.forEach { $0.close() }
        windowControllerList = []

        NSScreen.screens.forEach { [weak self] screen in
            guard let self else { return }
            let windowController = self.buildWallpaperWindow(screen: screen)
            self.windowControllerList.append(windowController)
            if screen == NSScreen.main {
                windowController.showWindow(nil, display: display)
            } else {
                let mutedWallpaperKind: WallpaperKind
                switch display {
                case .video(let value):
                    mutedWallpaperKind = .video(value: .init(url: value.url, mute: true, videoSize: value.videoSize))
                case .youtube(let videoId, let isMute):
                    mutedWallpaperKind = .youtube(videoId: videoId, isMute: !isMute)
                case .web:
                    mutedWallpaperKind = display
                case .none:
                    mutedWallpaperKind = display
                }
                windowController.showWindow(nil, display: mutedWallpaperKind)
            }
            windowController.fitFrame(computeFittingWallpaperSize(screen: screen))
        }
    }
    
    func hide() {
        windowControllerList.forEach { $0.close() }
        windowControllerList = []
    }

    func isVisibleWallpaperWindow() -> Bool {
        windowControllerList.contains { $0.window?.isVisible == true }
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

    private func computeFittingWallpaperSize(screen: NSScreen) -> NSRect {
        let topMargin = (screen.frame.height - screen.visibleFrame.height) - (screen.visibleFrame.origin.y - screen.frame.origin.y)
        return NSRect(
            x: screen.frame.origin.x,
            y: screen.frame.origin.y,
            width: screen.frame.size.width,
            height: screen.frame.size.height - topMargin
        )
    }
}
