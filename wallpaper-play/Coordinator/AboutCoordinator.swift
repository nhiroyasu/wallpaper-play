import Foundation

import AppKit
import Swinject
import Injectable

class AboutContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)
        
        return container
    }
}

class AboutCoordinator: Coordinator {
    private var viewController: AboutViewController!
    private let injector: Injectable
    
    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        viewController = AboutViewController()
        return viewController
    }
}

