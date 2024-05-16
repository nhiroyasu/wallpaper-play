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
            let wallpaperWindowFrame = computeFittingWallpaperSize(screen: screen)
            let windowController = self.buildWallpaperWindow(screen: screen, wallpaperSize: wallpaperWindowFrame.size)
            self.windowControllerList.append(windowController)
            if screen == NSScreen.main {
                windowController.showWindow(nil, display: display)
            } else {
                let mutedWallpaperKind: WallpaperKind
                switch display {
                case .video(let value):
                    mutedWallpaperKind = .video(value: .init(url: value.url, mute: true, videoSize: value.videoSize))
                case .youtube(let videoId, _):
                    mutedWallpaperKind = .youtube(videoId: videoId, isMute: true)
                case .web:
                    mutedWallpaperKind = display
                case .none:
                    mutedWallpaperKind = display
                }
                windowController.showWindow(nil, display: mutedWallpaperKind)
            }
            windowController.fitFrame(wallpaperWindowFrame)
        }
    }
    
    func hide() {
        windowControllerList.forEach { $0.close() }
        windowControllerList = []
    }

    func isVisibleWallpaperWindow() -> Bool {
        windowControllerList.contains { $0.window?.isVisible == true }
    }

    private func buildWallpaperWindow(screen: NSScreen, wallpaperSize: NSSize) -> WallMovieWindowController {
        let coordinator = WallMovieCoordinator(
            injector: Injector(container: WallMovieContainerBuilder.build(parent: Injector.shared.container)),
            wallpaperSize: wallpaperSize
        )
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
            // NOTE: There is a 1px gap between the Window and the StatusMenu, so I am adding +1px to close it.
            height: screen.frame.size.height - topMargin + 1
        )
    }
}
