import Foundation

import AppKit
import Swinject
import Injectable

class SettingCoordinator: Coordinator {
    private let localVideoSelectionCoordinator: LocalVideoSelectionCoordinator
    private let youtubeSelectionCoordinator: YouTubeSelectionCoordinator
    private let webpageSelectionCoordinator: WebPageSelectionCoordinator
    private let browserExtensionCoordinator: BrowserExtensionCoordinator
    private let preferenceCoordinator: PreferenceCoordinator
    private let aboutCoordinator: AboutCoordinator
    private var viewController: SettingSplitViewController!
    
    init() {
        self.localVideoSelectionCoordinator = .init(
            injector: Injector(
                container: LocalVideoSelectionContainerBuilder.build(
                    parent: Injector.shared.container
                )
            )
        )
        self.youtubeSelectionCoordinator = .init(
            injector: Injector(
                container: YouTubeSelectionContainerBuilder.build(
                    parent: Injector.shared.container
                )
            )
        )
        let state = WebPageSelectionState()
        self.webpageSelectionCoordinator = .init(
            injector: Injector(
                container: WebPageSelectionContainerBuilder.build(
                    parent: Injector.shared.container,
                    state: state
                )
            ),
            state: state
        )
        self.browserExtensionCoordinator = .init(
            injector: Injector(
                container: BrowserExtensionContainerBuilder.build(
                    parent: Injector.shared.container
                )
            )
        )
        self.preferenceCoordinator = .init(
            injector: Injector(
                container: PreferenceContainerBuilder.build(
                    parent: Injector.shared.container
                )
            )
        )
        self.aboutCoordinator = .init(
            injector: Injector(
                container: AboutContainerBuilder.build(
                    parent: Injector.shared.container
                )
            )
        )
    }
    
    func create() -> NSViewController {
        viewController = NSStoryboard.main?.instantiateController(withIdentifier: "SettingSplitViewController") as? SettingSplitViewController
        viewController.localVideoSelectionViewController = localVideoSelectionCoordinator.create() as? LocalVideoSelectionViewController
        viewController.youtubeSelectionViewController = youtubeSelectionCoordinator.create() as? YouTubeSelectionViewController
        viewController.webpageSelectionViewController = webpageSelectionCoordinator.create() as? WebPageSelectionViewController
        viewController.browserExtensionViewController = browserExtensionCoordinator.create() as? BrowserExtensionViewController
        viewController.preferenceViewController = preferenceCoordinator.create() as? PreferenceViewController
        viewController.aboutViewController = aboutCoordinator.create() as? AboutViewController
        return viewController
    }
}
