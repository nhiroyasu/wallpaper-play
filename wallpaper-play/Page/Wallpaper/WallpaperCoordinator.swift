import AppKit
import Swinject
import Injectable

class WallpaperCoordinator: WindowCoordinator {
    private var viewController: WallpaperViewController!
    private var window: WallpaperWindow!
    private let injector: any Injectable
    private let wallpaperSize: NSSize
    private let wallpaperKind: WallpaperKind

    init(injector: any Injectable, wallpaperSize: NSSize, wallpaperKind: WallpaperKind) {
        self.injector = injector
        self.wallpaperSize = wallpaperSize
        self.wallpaperKind = wallpaperKind
    }
    
    func createWindow() -> NSWindow {
        let presenter = WallpaperPresenterImpl(
            wallpaperKind: wallpaperKind,
            youtubeContentService: injector.build()
        )
        viewController = WallpaperViewController(wallpaperSize: wallpaperSize, presenter: presenter, avManager: injector.build())
        presenter.output = viewController
        window = WallpaperWindow(contentViewController: viewController)
        return window
    }
}
