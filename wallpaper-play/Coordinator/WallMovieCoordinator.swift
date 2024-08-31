import AppKit
import Swinject
import Injectable

class WallMovieCoordinator: WindowCoordinator {
    private var viewController: WallMovieViewController!
    private var window: WallMovieWindow!
    private let injector: Injectable
    private let wallpaperSize: NSSize
    private let wallpaperKind: WallpaperKind

    init(injector: Injectable, wallpaperSize: NSSize, wallpaperKind: WallpaperKind) {
        self.injector = injector
        self.wallpaperSize = wallpaperSize
        self.wallpaperKind = wallpaperKind
    }
    
    func createWindow() -> NSWindow {
        let presenter = WallMoviePresenterImpl(
            wallpaperKind: wallpaperKind,
            youtubeContentService: injector.build()
        )
        viewController = WallMovieViewController(wallpaperSize: wallpaperSize, presenter: presenter, avManager: injector.build())
        presenter.output = viewController
        window = WallMovieWindow(contentViewController: viewController)
        return window
    }
}
