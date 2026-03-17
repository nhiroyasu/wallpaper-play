import AppKit
import Swinject
import Injectable

class AboutCoordinator: EntryCoordinator {
    private var viewController: AboutViewController!
    private let injector: any Injectable
    
    init(injector: any Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        viewController = AboutViewController(injector: injector)
        return viewController
    }
}

