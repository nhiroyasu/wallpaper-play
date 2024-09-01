import AppKit
import Swinject
import Injectable

class PreferenceCoordinator: Coordinator {
    private var viewController: PreferenceViewController!
    private let injector: any Injectable

    init(injector: any Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        let useCase = PreferenceInteractor(injector: injector)
        let presenter = PreferencePresenterImpl(useCase: useCase)
        viewController = PreferenceViewController(presenter: presenter)
        presenter.output = viewController
        return viewController
    }
}
