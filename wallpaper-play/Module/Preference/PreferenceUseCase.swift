import Foundation
import Injectable

protocol PreferenceUseCase {
    func setUp()
    func updateLaunchAtLoginSetting(_ value: Bool)
    func updateVisibilityIconSetting(_ value: Bool)
    func updateOpenThisWindowAtFirst(_ value: Bool)
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
        presenter.setUpUI(PreferenceSetUpOutput(
            launchAtLogin: userSetting.launchAtLogin,
            visibilityIcon: userSetting.visibilityIcon,
            openThisWindowAtFirst: userSetting.openThisWindowAtFirst
        ))
    }

    fileprivate func reloadData() {
        presenter.updateViewData(PreferenceSetUpOutput(
            launchAtLogin: userSetting.launchAtLogin,
            visibilityIcon: userSetting.visibilityIcon,
            openThisWindowAtFirst: userSetting.openThisWindowAtFirst
        ))
    }

    func updateLaunchAtLoginSetting(_ value: Bool) {
        userSetting.launchAtLogin = value
        reloadData()
    }
    
    func updateVisibilityIconSetting(_ value: Bool) {
        userSetting.visibilityIcon = value
        reloadData()
    }

    func updateOpenThisWindowAtFirst(_ value: Bool) {
        userSetting.openThisWindowAtFirst = value
        reloadData()
    }
}

