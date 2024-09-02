import AppKit
import Swinject
import Injectable

class BrowserExtensionCoordinator: Coordinator {
    private var viewController: BrowserExtensionViewController!
    private let injector: any Injectable

    init(injector: any Injectable) {
        self.injector = injector
    }

    func create() -> NSViewController {
        viewController = BrowserExtensionViewController()
        return viewController
    }
}
