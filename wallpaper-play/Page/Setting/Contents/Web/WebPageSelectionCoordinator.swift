import AppKit
import Swinject
import Injectable

class WebPageSelectionCoordinator: Coordinator {
    private var viewController: WebPageSelectionViewController!
    private let injector: Injectable

    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        let useCase = WebPageSelectionInteractor(
            wallpaperRequestService: injector.build(),
            urlValidationService: injector.build()
        )
        let presenter = WebPageSelectionPresenterImpl(
            useCase: useCase,
            alertManager: injector.build()
        )
        viewController = WebPageSelectionViewController(presenter: presenter)
        presenter.output = viewController
        return viewController
    }
}
