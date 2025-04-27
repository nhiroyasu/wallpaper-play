import AppKit
import Injectable

protocol WallpaperWindowService {
    func display(wallpaperKind: WallpaperKind, target: WallpaperDisplayTarget)
    func hide()
    func isVisibleWallpaperWindow() -> Bool
}

class WallpaperWindowServiceImpl: WallpaperWindowService {
    private var windowList: [NSWindow] = []
    private let wallpaperHistoryService: any WallpaperHistoryService
    private let notificationManager: any NotificationManager
    private let youTubeContentsService: any YouTubeContentsService
    private let appState: AppState

    init(injector: any Injectable) {
        self.notificationManager = injector.build()
        self.wallpaperHistoryService = injector.build()
        self.youTubeContentsService = injector.build()
        self.appState = injector.build()
    }
    
    func display(wallpaperKind: WallpaperKind, target: WallpaperDisplayTarget) {
        switch target {
        case .sameOnAllMonitors:
            // reset all wallpaper windows and remove all wallpaper states
            windowList.forEach { $0.close() }
            windowList = []
            appState.wallpapers.removeAll()

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

                // save wallpaper state
                appState.wallpapers.append(.init(
                    screenIdentifier: screen.deviceIdentifier,
                    kind: actualWallpaperKind
                ))
            }

        case .specificMonitor(let screen):
            // reset wallpaper window and remove wallpaper state on the specific screen
            let windowInTargetScreens = windowList.filter { $0.screen == screen }
            windowInTargetScreens.forEach { $0.close() }
            windowList.removeAll { $0.screen == screen }

            let wallpaperWindowFrame = computeFittingWallpaperSize(screen: screen)
            let windowLevel = computeWindowLevel(wallpaperKind: wallpaperKind)
            let window = buildWallpaperWindow(
                screen: screen,
                windowLevel: windowLevel,
                wallpaperSize: wallpaperWindowFrame.size,
                wallpaperKind: wallpaperKind
            )
            window.orderFront(nil)
            windowList.append(window)
            window.setFrame(wallpaperWindowFrame, display: true)

            // save wallpaper state
            appState.wallpapers.removeAll { $0.screenIdentifier == screen.deviceIdentifier }
            appState.wallpapers.append(.init(
                screenIdentifier: screen.deviceIdentifier,
                kind: wallpaperKind
            ))
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
        case .video, .youtube, .unknown:
            return .desktopAbove
        case let .web(_, arrowOperation):
            return arrowOperation ? .desktopIconAbove : .desktopAbove
        case .camera:
            return .desktopIconAbove
        }
    }

    private func muteWallpaperKindIfNeeded(baseWallpaperKind: WallpaperKind, on screen: NSScreen) -> WallpaperKind {
        if screen == NSScreen.main {
            return baseWallpaperKind
        }
        switch baseWallpaperKind {
        case .video(let url, _, let videoSize, let backgroundColor):
            return .video(url: url, mute: true, videoSize: videoSize, backgroundColor: backgroundColor)
        case .youtube(let videoId, _, let videoSize):
            return .youtube(videoId: videoId, isMute: true, videoSize: videoSize)
        case .web, .camera, .unknown:
            return baseWallpaperKind
        }
    }
}
