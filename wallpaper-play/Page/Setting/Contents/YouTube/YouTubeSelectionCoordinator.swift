import AppKit
import Swinject
import Injectable

class YouTubeSelectionCoordinator: Coordinator {
    private var viewController: YouTubeSelectionViewController!
    private let injector: Injectable

    init(injector: Injectable) {
        self.injector = injector
    }
    
    func create() -> NSViewController {
        let useCase = YouTubeSelectionInteractor(
            urlResolverService: injector.build(),
            youtubeContentService: injector.build(),
            wallpaperRequestService: injector.build()
        )
        let presenter = YouTubeSelectionPresenterImpl(
            useCase: useCase,
            alertService: injector.build()
        )
        viewController = YouTubeSelectionViewController(presenter: presenter)
        presenter.output = viewController
        return viewController
    }
}
