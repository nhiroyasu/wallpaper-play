import Foundation
import AppKit
import Swinject
import Injectable

class CameraSelectionCoordinator: Coordinator {
    private var viewController: CameraSelectionViewController!
    private let injector: any Injectable

    init(injector: any Injectable) {
        self.injector = injector
    }

    func create() -> NSViewController {
        let useCase = CameraSelectionInteractor(
            wallpaperRequestService: injector.build()
        )
        let presenter = CameraSelectionPresenterImpl(
            useCase: useCase,
            alertManager: injector.build(),
            fileSelectionService: injector.build()
        )
        viewController = CameraSelectionViewController(
            presenter: presenter,
            notificationManager: injector.build(),
            cameraDeviceService: injector.build(),
            appState: injector.build()
        )
        presenter.output = viewController
        return viewController
    }
}
