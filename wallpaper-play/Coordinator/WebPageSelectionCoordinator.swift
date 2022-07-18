import AppKit
import Swinject
import Injectable

class WebPageSelectionContainerBuilder {
    static func build(parent: Container?, state: WebPageSelectionState) -> Container {
        let container = Container(parent: parent)
        
        container.register(WebPageSelectionAction.self) { resolver in
            WebPageSelectionActionImpl(injector: resolver, state: state)
        }.inObjectScope(.container)
        container.register(WebPageSelectionUseCase.self) { resolver in
            WebPageSelectionInteractor(injector: resolver)
        }.inObjectScope(.container)
        container.register(WebPageSelectionPresenter.self) { resolver in
            WebPageSelectionPresenterImpl(injector: resolver, state: state)
        }.inObjectScope(.container)
        
        return container
    }
}

class WebPageSelectionCoordinator: Coordinator {
    private var viewController: WebPageSelectionViewController!
    private let injector: Injectable
    private lazy var action: WebPageSelectionAction = injector.build()
    private lazy var useCase: WebPageSelectionUseCase = injector.build()
    private lazy var presenter: WebPageSelectionPresenter = injector.build()
    private let state: WebPageSelectionState
    
    init(injector: Injectable, state: WebPageSelectionState) {
        self.injector = injector
        self.state = state
    }
    
    func create() -> NSViewController {
        viewController = WebPageSelectionViewController(action: action, state: state)
        return viewController
    }
}
