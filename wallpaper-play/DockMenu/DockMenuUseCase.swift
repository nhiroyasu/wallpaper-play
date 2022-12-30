import Foundation
import Injectable

protocol DockMenuUseCase {
    func showPreference()
}

final class DockMenuInteractor: DockMenuUseCase {
    private let notificationManager: NotificationManager
    private let videoFormWindowPresenter: VideoFormWindowPresenter
    private let appManager: AppManager

    init(injector: Injectable) {
        notificationManager = injector.build()
        videoFormWindowPresenter = injector.build()
        appManager = injector.build()
    }

    func showPreference() {
        videoFormWindowPresenter.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.notificationManager.push(name: .selectedSideMenu, param: SideMenuItem.preference)
        }
        appManager.activate()
    }
}
