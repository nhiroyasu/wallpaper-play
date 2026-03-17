import Foundation
import Injectable

protocol DockMenuUseCase {
    func showPreference()
}

final class DockMenuInteractor: DockMenuUseCase {
    private let notificationManager: any NotificationManager
    private let appManager: any AppManager

    init(injector: any Injectable) {
        notificationManager = injector.build()
        appManager = injector.build()
    }

    func showPreference() {
        self.notificationManager.push(name: .showSettingWindowWithPreferenceMenu, param: nil)
        appManager.activate()
    }
}
