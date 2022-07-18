import Foundation
import Injectable

protocol WallMovieUseCase {
    func setUp(screenFrame: NSRect)
    func requestWallpaper(_ type: WallpaperKind)
}

class WallMovieInteractor: WallMovieUseCase {
    
    private let presenter: WallMoviePresenter
    private let youtubeContentService: YouTubeContentsService
    private let systemWallpaperService: SystemWallpaperService
    
    internal init(injector: Injectable = Injector.shared) {
        self.presenter = injector.build(WallMoviePresenter.self)
        self.youtubeContentService = injector.build()
        self.systemWallpaperService = injector.build()
    }
    
    func setUp(screenFrame: NSRect) {
        presenter.initViews(screenFrame: screenFrame)
    }
    
    func requestWallpaper(_ type: WallpaperKind) {
        presenter.display(openType: type)
    }
}
