import Foundation

import AppKit
import Swinject
import Injectable

class VideoFormContainerBuilder {
    static func build(parent: Container?) -> Container {
        let container = Container(parent: parent)

        return container
    }
}

class VideoFormCoordinator: Coordinator {
    private let localVideoSelectionCoordinator: LocalVideoSelectionCoordinator
    private let youtubeSelectionCoordinator: YouTubeSelectionCoordinator
    private let webpageSelectionCoordinator: WebPageSelectionCoordinator
    private let preferenceCoordinator: PreferenceCoordinator
    private var viewController: VideoFormSplitViewController!
    
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
        self.preferenceCoordinator = .init(
            injector: Injector(
                container: PreferenceContainerBuilder.build(
                    parent: Injector.shared.container
                )
            )
        )
    }
    
    func create() -> NSViewController {
        viewController = NSStoryboard.main?.instantiateController(withIdentifier: "VideoFormSplitViewController") as? VideoFormSplitViewController
        viewController.localVideoSelectionViewController = localVideoSelectionCoordinator.create() as? LocalVideoSelectionViewController
        viewController.youtubeSelectionViewController = youtubeSelectionCoordinator.create() as? YouTubeSelectionViewController
        viewController.webpageSelectionViewController = webpageSelectionCoordinator.create() as? WebPageSelectionViewController
        viewController.preferenceViewController = preferenceCoordinator.create() as? PreferenceViewController
        return viewController
    }
}
