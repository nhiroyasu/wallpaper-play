import AppKit
import SwiftUI
import Swinject
import Injectable

class PlaylistFormCoordinator: PresentCoordinator {
    private var viewController: PlaylistFormViewController!
    private let injector: any Injectable
    private let context: PlaylistFormContext
    private let submitCompletion: (() -> Void)?

    init(
        injector: any Injectable,
        context: PlaylistFormContext,
        submitCompletion: (() -> Void)?
    ) {
        self.injector = injector
        self.context = context
        self.submitCompletion = submitCompletion
    }

    func present(from parentVC: NSViewController) {
        let vc = createVC()
        parentVC.presentAsSheet(vc)
    }

    private func createVC() -> NSViewController {
        let useCase = PlaylistFormUseCaseImpl(injector: injector)
        let vm = PlaylistFormViewModelImpl(
            injector: injector,
            useCase: useCase,
            context: context,
            submitCompletion: submitCompletion
        )
        vm.transitionDelegate = self
        let view = PlaylistFormScreenView(vm: vm)
        viewController = PlaylistFormViewController(rootView: view)
        return viewController
    }
}

extension PlaylistFormCoordinator: PlaylistFormTransitionDelegate {
    func dismiss() {
        viewController.dismiss(nil)
    }
}

class PlaylistFormViewController: NSHostingController<PlaylistFormScreenView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
