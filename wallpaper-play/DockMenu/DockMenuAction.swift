import Injectable

protocol DockMenuAction {
    func preferenceAction()
}

final class DockMenuActionImpl: DockMenuAction {
    private let useCase: DockMenuUseCase

    init(injector: Injectable) {
        useCase = injector.build()
    }

    func preferenceAction() {
        useCase.showPreference()
    }
}
