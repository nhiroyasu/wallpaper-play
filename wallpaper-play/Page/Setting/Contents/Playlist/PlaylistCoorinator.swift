import AppKit
import SwiftUI
import Swinject
import Injectable

class PlaylistCoordinator: EntryCoordinator {
    private var viewController: PlaylistViewController!
    private let injector: any Injectable
    private var playlistFormCoordinator: PlaylistFormCoordinator?

    init(injector: any Injectable) {
        self.injector = injector
    }

    func create() -> NSViewController {
        let useCase = PlaylistUseCaseImpl(injector: injector)
        let vm = PlaylistViewModelImpl(useCase: useCase)
        vm.transitionDelegate = self
        let view = PlaylistScreenView(vm: vm)
        viewController = PlaylistViewController(rootView: view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.autoresizesSubviews = true
        return viewController
    }
}

extension PlaylistCoordinator: PlaylistTransitionDelegate {
    func transitionToPlaylistForm(submitCompletion: (() -> Void)?) {
        playlistFormCoordinator = PlaylistFormCoordinator(
            injector: injector,
            submitCompletion: submitCompletion
        )
        playlistFormCoordinator?.present(from: viewController)
    }
}

class PlaylistViewController: NSHostingController<PlaylistScreenView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
