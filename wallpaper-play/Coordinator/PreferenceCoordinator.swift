import AppKit
import Swinject
import Injectable

class PreferenceContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        
        container.register(PreferenceAction.self) { resolver in
            PreferenceActionImpl(injector: resolver)
        }.inObjectScope(.container)
        container.register(PreferenceUseCase.self) { resolver in
            PreferenceInteractor(injector: resolver)
        }.inObjectScope(.container)
        container.register(PreferencePresenter.self) { resolver in
            PreferencePresenterImpl(injector: resolver)
        }.inObjectScope(.container)
        
        return container
    }
}

class PreferenceCoordinator: Coordinator {
    private var viewController: PreferenceViewController!
    private let injector: Injectable
    private lazy var action: PreferenceAction = injector.build()
    private lazy var useCase: PreferenceUseCase = injector.build()
    private lazy var presenter: PreferencePresenter = injector.build()
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        viewController = PreferenceViewController(action: action)
        (presenter as? PreferencePresenterImpl)?.viewController = viewController
        return viewController
    }
}
