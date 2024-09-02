import Injectable

protocol DockMenuAction {
    func preferenceAction()
}

final class DockMenuActionImpl: DockMenuAction {
    private let useCase: any DockMenuUseCase

    init(injector: any Injectable) {
        useCase = injector.build()
    }

    func preferenceAction() {
        useCase.showPreference()
    }
}
