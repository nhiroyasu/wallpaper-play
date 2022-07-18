import Foundation
import Injectable

protocol PreferenceUseCase {
    func setUp()
    func updateLaunchAtLoginSetting(_ value: Bool)
    func updateVisibilityIconSetting(_ value: Bool)
}

class PreferenceInteractor: PreferenceUseCase {
    
    private var userSetting: UserSettingService
    private let presenter: PreferencePresenter
    private let notificationManager: NotificationManager
    private let appManager: AppManager
    
    internal init(injector: Injectable = Injector.shared) {
        self.userSetting = injector.build()
        self.presenter = injector.build(PreferencePresenter.self)
        self.appManager = injector.build()
        self.notificationManager = injector.build()
    }
    
    func setUp() {
        presenter.setUpUI(.init(
            launchAtLogin: userSetting.launchAtLogin,
            visibilityIcon: userSetting.visibilityIcon
        ))
    }
    
    func updateLaunchAtLoginSetting(_ value: Bool) {
        userSetting.launchAtLogin = value
    }
    
    func updateVisibilityIconSetting(_ value: Bool) {
        userSetting.visibilityIcon = value
    }
}

