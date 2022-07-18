import Foundation

import AppKit
import Swinject
import Injectable

class LocalVideoSelectionContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        
        container.register(LocalVideoSelectionAction.self) { resolver in
            LocalVideoSelectionActionImpl(injector: resolver)
        }.inObjectScope(.container)
        container.register(LocalVideoSelectionUseCase.self) { resolver in
            LocalVideoSelectionInteractor(injector: resolver)
        }.inObjectScope(.container)
        container.register(LocalVideoSelectionPresenter.self) { resolver in
            LocalVideoSelectionPresenterImpl(injector: resolver)
        }.inObjectScope(.container)
        
        return container
    }
}

class LocalVideoSelectionCoordinator: Coordinator {
    private var viewController: LocalVideoSelectionViewController!
    private let injector: Injectable
    private lazy var action: LocalVideoSelectionAction = injector.build()
    private lazy var useCase: LocalVideoSelectionUseCase = injector.build()
    private lazy var presenter: LocalVideoSelectionPresenter = injector.build()
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        viewController = LocalVideoSelectionViewController(action: action)
        (presenter as? LocalVideoSelectionPresenterImpl)?.output = viewController
        return viewController
    }
}
