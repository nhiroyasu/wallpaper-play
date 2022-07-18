import AppKit
import Swinject
import Injectable

class WallMovieContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        
        container.register(WallMovieAction.self) { resolver in
            WallMovieActionImpl(injector: resolver)
        }.inObjectScope(.container)
        container.register(WallMovieUseCase.self) { resolver in
            WallMovieInteractor(injector: resolver)
        }.inObjectScope(.container)
        container.register(WallMoviePresenter.self) { resolver in
            WallMoviePresenterImpl(injector: resolver)
        }.inObjectScope(.container)
        
        return container
    }
}

class WallMovieCoordinator: Coordinator {
    private var viewController: WallMovieViewController!
    private let injector: Injectable
    private lazy var action: WallMovieAction = injector.build()
    private lazy var useCase: WallMovieUseCase = injector.build()
    private lazy var presenter: WallMoviePresenter = injector.build()
    private let screenFrame: NSRect
    
    init(injector: Injectable, screenFrame: NSRect) {
        self.injector = injector
        self.screenFrame = screenFrame
    }
    
    func create() -> NSViewController {
        viewController = WallMovieViewController(screenFrame: screenFrame, action: action)
        (presenter as? WallMoviePresenterImpl)?.output = viewController
        return viewController
    }
}
