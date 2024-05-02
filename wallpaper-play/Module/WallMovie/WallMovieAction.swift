import Foundation
import Injectable

protocol WallMovieAction {
    func viewDidLoad()
    func viewWillDisappear()
    func show(_ type: WallpaperKind)
}

class WallMovieActionImpl: WallMovieAction {
    
    private let useCase: WallMovieUseCase
    
    public init(injector: Injectable = Injector.shared) {
        self.useCase = injector.build(WallMovieUseCase.self)
    }
    
    func viewDidLoad() {
        useCase.setUp()
    }
    
    func viewWillDisappear() {
    }
    
    func show(_ type: WallpaperKind) {
        useCase.requestWallpaper(type)
    }
}
