import Foundation
import Injectable

protocol PreferenceUseCase {
    func getLaunchAtLoginSetting() -> Bool
    func getVisibilityIconSetting() -> Bool
    func getOpenThisWindowAtFirst() -> Bool
    func updateLaunchAtLoginSetting(_ value: Bool)
    func updateVisibilityIconSetting(_ value: Bool)
    func updateOpenThisWindowAtFirst(_ value: Bool)
}

class PreferenceInteractor: PreferenceUseCase {
    
    private var userSetting: any UserSettingService

    internal init(injector: any Injectable) {
        self.userSetting = injector.build()
    }

    func getLaunchAtLoginSetting() -> Bool {
        userSetting.launchAtLogin
    }

    func getVisibilityIconSetting() -> Bool {
        userSetting.visibilityIcon
    }

    func getOpenThisWindowAtFirst() -> Bool {
        userSetting.openThisWindowAtFirst
    }

    func updateLaunchAtLoginSetting(_ value: Bool) {
        userSetting.launchAtLogin = value
    }
    
    func updateVisibilityIconSetting(_ value: Bool) {
        userSetting.visibilityIcon = value
    }

    func updateOpenThisWindowAtFirst(_ value: Bool) {
        userSetting.openThisWindowAtFirst = value
    }
}

