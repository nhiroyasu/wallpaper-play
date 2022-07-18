import Foundation

import AppKit
import Swinject
import Injectable

class YouTubeSelectionContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        
        container.register(YouTubeSelectionAction.self) { resolver in
            YouTubeSelectionActionImpl(injector: resolver)
        }.inObjectScope(.container)
        container.register(YouTubeSelectionUseCase.self) { resolver in
            YouTubeSelectionInteractor(injector: resolver)
        }.inObjectScope(.container)
        container.register(YouTubeSelectionPresenter.self) { resolver in
            YouTubeSelectionPresenterImpl(injector: resolver)
        }.inObjectScope(.container)
        
        return container
    }
}

class YouTubeSelectionCoordinator: Coordinator {
    private var viewController: YouTubeSelectionViewController!
    private let injector: Injectable
    private lazy var action: YouTubeSelectionAction = injector.build()
    private lazy var useCase: YouTubeSelectionUseCase = injector.build()
    private lazy var presenter: YouTubeSelectionPresenter = injector.build()
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        viewController = YouTubeSelectionViewController(action: action)
        (presenter as? YouTubeSelectionPresenterImpl)?.output = viewController
        return viewController
    }
}
