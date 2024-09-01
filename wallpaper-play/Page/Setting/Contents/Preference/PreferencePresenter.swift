import Foundation
import Injectable
import AppKit

protocol PreferencePresenter {
    func viewDidLoad()
    func didTapLaunchAtLogin(state: Bool)
    func didTapVisibilityIcon(state: Bool)
    func didTapOpenThisWindowAtFirst(state: Bool)
}

class PreferencePresenterImpl: PreferencePresenter {
    private let useCase: any PreferenceUseCase
    weak var output: (any PreferenceViewOutput)!

    init(useCase: any PreferenceUseCase) {
        self.useCase = useCase
    }

    func viewDidLoad() {
        output.reload(.init(
            launchAtLogin: useCase.getLaunchAtLoginSetting(),
            visibilityIcon: useCase.getVisibilityIconSetting(),
            openThisWindowAtFirst: useCase.getOpenThisWindowAtFirst()
        ))
    }

    func didTapLaunchAtLogin(state: Bool) {
        useCase.updateLaunchAtLoginSetting(state)
    }

    func didTapVisibilityIcon(state: Bool) {
        useCase.updateVisibilityIconSetting(state)
    }

    func didTapOpenThisWindowAtFirst(state: Bool) {
        useCase.updateOpenThisWindowAtFirst(state)
    }
}
