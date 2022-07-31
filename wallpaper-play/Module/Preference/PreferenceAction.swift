import Foundation
import Injectable

protocol PreferenceAction {
    func viewDidLoad()
    func didTapLaunchAtLogin(state: Bool)
    func didTapVisibilityIcon(state: Bool)
    func didTapOpenThisWindowAtFirst(state: Bool)
}

class PreferenceActionImpl: PreferenceAction {
    
    private let useCase: PreferenceUseCase
    
    public init(injector: Injectable = Injector.shared) {
        self.useCase = injector.build(PreferenceUseCase.self)
    }
    
    func viewDidLoad() {
        useCase.setUp()
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




