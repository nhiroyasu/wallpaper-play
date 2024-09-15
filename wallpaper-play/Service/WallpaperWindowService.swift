import AppKit
import Injectable

protocol WallpaperWindowService {
    func display(wallpaperKind: WallpaperKind)
    func hide()
    func isVisibleWallpaperWindow() -> Bool
}

class WallpaperWindowServiceImpl: WallpaperWindowService {
    private var windowList: [NSWindow] = []
    private let wallpaperHistoryService: any WallpaperHistoryService
    private let notificationManager: any NotificationManager
    private let youTubeContentsService: any YouTubeContentsService
    
    init(injector: any Injectable) {
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
            let windowLevel = computeWindowLevel(wallpaperKind: wallpaperKind)
            let actualWallpaperKind = muteWallpaperKindIfNeeded(baseWallpaperKind: wallpaperKind, on: screen)
            let window = buildWallpaperWindow(
                screen: screen,
                windowLevel: windowLevel,
                wallpaperSize: wallpaperWindowFrame.size,
                wallpaperKind: actualWallpaperKind
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

    private func buildWallpaperWindow(
        screen: NSScreen,
        windowLevel: NSWindow.Level,
        wallpaperSize: NSSize,
        wallpaperKind: WallpaperKind
    ) -> NSWindow {
        let coordinator = WallpaperCoordinator(
            injector: Injector.shared,
            windowLevel: windowLevel,
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

    private func computeWindowLevel(wallpaperKind: WallpaperKind) -> NSWindow.Level {
        switch wallpaperKind {
        case .video, .youtube, .none:
            return .desktopAbove
        case let .web(_, arrowOperation):
            return arrowOperation ? .desktopIconAbove : .desktopAbove
        }
    }

    private func muteWallpaperKindIfNeeded(baseWallpaperKind: WallpaperKind, on screen: NSScreen) -> WallpaperKind {
        if screen == NSScreen.main {
            return baseWallpaperKind
        }
        switch baseWallpaperKind {
        case .video(let value):
            return .video(
                value: .init(
                    url: value.url,
                    mute: true,
                    videoSize: value.videoSize,
                    backgroundColor: value.backgroundColor
                )
            )
        case .youtube(let videoId, _):
            return .youtube(videoId: videoId, isMute: true)
        case .web, .none:
            return baseWallpaperKind
        }
    }
}
