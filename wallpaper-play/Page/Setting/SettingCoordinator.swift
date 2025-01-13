import Foundation

import AppKit
import Swinject
import Injectable

class SettingCoordinator: Coordinator {
    private let localVideoSelectionCoordinator: LocalVideoSelectionCoordinator
    private let youtubeSelectionCoordinator: YouTubeSelectionCoordinator
    private let webpageSelectionCoordinator: WebPageSelectionCoordinator
    private let cameraSelectionCoordinator: CameraSelectionCoordinator
    private let browserExtensionCoordinator: BrowserExtensionCoordinator
    private let preferenceCoordinator: PreferenceCoordinator
    private let aboutCoordinator: AboutCoordinator
    private var viewController: SettingSplitViewController!

    init(injector: any Injectable) {
        self.localVideoSelectionCoordinator = .init(injector: injector)
        self.youtubeSelectionCoordinator = .init(injector: injector)
        self.webpageSelectionCoordinator = .init(injector: injector)
        self.cameraSelectionCoordinator = .init(injector: injector)
        self.browserExtensionCoordinator = .init(injector: injector)
        self.preferenceCoordinator = .init(injector: injector)
        self.aboutCoordinator = .init(injector: injector)
    }
    
    func create() -> NSViewController {
        viewController = NSStoryboard.main?.instantiateController(withIdentifier: "SettingSplitViewController") as? SettingSplitViewController
        viewController.localVideoSelectionViewController = localVideoSelectionCoordinator.create() as? LocalVideoSelectionViewController
        viewController.youtubeSelectionViewController = youtubeSelectionCoordinator.create() as? YouTubeSelectionViewController
        viewController.webpageSelectionViewController = webpageSelectionCoordinator.create() as? WebPageSelectionViewController
        viewController.cameraSelectionViewController = cameraSelectionCoordinator.create() as? CameraSelectionViewController
        viewController.browserExtensionViewController = browserExtensionCoordinator.create() as? BrowserExtensionViewController
        viewController.preferenceViewController = preferenceCoordinator.create() as? PreferenceViewController
        viewController.aboutViewController = aboutCoordinator.create() as? AboutViewController
        return viewController
    }
}
