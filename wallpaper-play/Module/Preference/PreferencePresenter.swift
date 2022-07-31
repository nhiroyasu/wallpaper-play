import Foundation
import Injectable
import AppKit

struct PreferenceSetUpOutput {
    let launchAtLogin: Bool
    let visibilityIcon: Bool
    let openThisWindowAtFirst: Bool
}

protocol PreferencePresenter {
    func setUpUI(_ output: PreferenceSetUpOutput)
}

class PreferencePresenterImpl: PreferencePresenter {
    var viewController: PreferenceViewController!

    init(injector: Injectable) {
    }
    
    func setUpUI(_ output: PreferenceSetUpOutput) {
        let preferenceCellList: [PreferenceCell] = [
            .launchAtLogin(viewData: SwitchCellViewData(
                switchState: output.launchAtLogin,
                title: "Launch this application at login",
                description: "If Selected, this application will launch even if your system restart."
            )),
            .visibilityIcon(viewData: SwitchCellViewData(
                switchState: output.visibilityIcon,
                title: "Display application icon",
                description: "If Selected, this application dock icon will be invisible. This is reflected after this window is closed."
            )),
            .openThisWindowAtFirst(viewData: SwitchCellViewData(
                switchState: output.openThisWindowAtFirst,
                title: "Open this window at application launch",
                description: "If Selected, this window will open when launch application."
            ))
        ]
        viewController.viewData = .init(switchPreferences: preferenceCellList)
        viewController.collectionView.reloadData()
    }
}
