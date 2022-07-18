import Foundation
import Injectable

protocol WallMovieAction {
    func viewDidLoad(screenFrame: NSRect)
    func viewWillDisappear()
    func show(_ type: WallpaperKind)
}

class WallMovieActionImpl: WallMovieAction {
    
    private let useCase: WallMovieUseCase
    
    public init(injector: Injectable = Injector.shared) {
        self.useCase = injector.build(WallMovieUseCase.self)
    }
    
    func viewDidLoad(screenFrame: NSRect) {
        useCase.setUp(screenFrame: screenFrame)
    }
    
    func viewWillDisappear() {
    }
    
    func show(_ type: WallpaperKind) {
        useCase.requestWallpaper(type)
    }
}
