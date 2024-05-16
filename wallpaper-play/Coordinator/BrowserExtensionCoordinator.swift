import AppKit
import Swinject
import Injectable

class BrowserExtensionContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        return container
    }
}

class BrowserExtensionCoordinator: Coordinator {
    private var viewController: BrowserExtensionViewController!
    private let injector: Injectable

    init(injector: Injectable) {
        self.injector = injector
    }

    func create() -> NSViewController {
        viewController = BrowserExtensionViewController()
        return viewController
    }
}
