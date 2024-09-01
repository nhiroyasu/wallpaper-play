import Foundation

import AppKit
import Swinject
import Injectable

class LocalVideoSelectionCoordinator: Coordinator {
    private var viewController: LocalVideoSelectionViewController!
    private let injector: any Injectable

    init(injector: any Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        let useCase = LocalVideoSelectionInteractor(
            wallpaperRequestService: injector.build()
        )
        let presenter = LocalVideoSelectionPresenterImpl(
            useCase: useCase,
            alertManager: injector.build(),
            fileSelectionService: injector.build()
        )
        viewController = LocalVideoSelectionViewController(
            presenter: presenter,
            avManager: injector.build()
        )
        presenter.output = viewController
        return viewController
    }
}
