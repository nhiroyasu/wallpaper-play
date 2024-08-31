import AppKit
import Injectable

protocol WallpaperWindowService {
    func display(wallpaperKind: WallpaperKind)
    func hide()
    func isVisibleWallpaperWindow() -> Bool
}

class WallpaperWindowServiceImpl: WallpaperWindowService {
    private var windowList: [NSWindow] = []
    private let wallpaperHistoryService: WallpaperHistoryService
    private let notificationManager: NotificationManager
    private let youTubeContentsService: YouTubeContentsService
    
    init(injector: Injectable) {
        self.notificationManager = injector.build()
        self.wallpaperHistoryService = injector.build()
        self.youTubeContentsService = injector.build()
        observeScreenParam()
    }
    
    func display(wallpaperKind: WallpaperKind) {
        windowList.forEach { $0.close() }
        windowList = []

        NSScreen.screens.forEach { [weak self] screen in
            guard let self else { return }
            let wallpaperWindowFrame = computeFittingWallpaperSize(screen: screen)
            let muteWallpaperKindIfNeeded: WallpaperKind = if screen == NSScreen.main {
                wallpaperKind
            } else {
                switch wallpaperKind {
                case .video(let value):
                    .video(value: .init(url: value.url, mute: true, videoSize: value.videoSize))
                case .youtube(let videoId, _):
                    .youtube(videoId: videoId, isMute: true)
                case .web, .none:
                    wallpaperKind
                }
            }
            let window = buildWallpaperWindow(
                screen: screen,
                wallpaperSize: wallpaperWindowFrame.size,
                wallpaperKind: muteWallpaperKindIfNeeded
            )
            window.orderFront(nil)
            windowList.append(window)
            window.setFrame(wallpaperWindowFrame, display: true)
        }
    }
    
    func hide() {
        windowList.forEach { $0.close() }
        windowList = []
    }

    func isVisibleWallpaperWindow() -> Bool {
        windowList.contains { $0.isVisible == true }
    }

    private func buildWallpaperWindow(screen: NSScreen, wallpaperSize: NSSize, wallpaperKind: WallpaperKind) -> NSWindow {
        let coordinator = WallpaperCoordinator(
            injector: Injector.shared,
            wallpaperSize: wallpaperSize,
            wallpaperKind: wallpaperKind
        )
        return coordinator.createWindow()
    }
    
    private func observeScreenParam() {
        notificationManager.observe(name: NSApplication.didChangeScreenParametersNotification) { [weak self] _ in
            guard let latestWallpaper = self?.wallpaperHistoryService.fetchLatestWallpaper() else { return }
            self?.display(wallpaperKind: latestWallpaper)
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
