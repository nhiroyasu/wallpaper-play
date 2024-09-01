import AppKit
import Swinject
import Injectable

class AboutCoordinator: Coordinator {
    private var viewController: AboutViewController!
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        viewController = AboutViewController(injector: injector)
        return viewController
    }
}

