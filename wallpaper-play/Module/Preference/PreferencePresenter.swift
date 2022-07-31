import Foundation
import Injectable
import AppKit

struct PreferenceSetUpOutput {
    let launchAtLogin: Bool
    let visibilityIcon: Bool
    let openThisWindowAtFirst: Bool
}

protocol PreferencePresenter {
    /// PreferenceViewの更新処理
    /// - Parameter output: Viewに必要な情報
    ///
    /// Outputを元にViewDataの更新と画面のリロードが行われる
    func setUpUI(_ output: PreferenceSetUpOutput)
    /// PreferenceViewのViewData更新
    /// - Parameter output: ViewDataに必要な情報
    ///
    /// Outputを元にViewDataの更新が行われる。
    ///
    /// Switchが独自に状態を持っていることによりデータを同期する必要があるため、このメソッドが存在する。（なんとかしたい）
    func updateViewData(_ output: PreferenceSetUpOutput)
}

class PreferencePresenterImpl: PreferencePresenter {
    var viewController: PreferenceViewController!

    init(injector: Injectable) {
    }
    
    func setUpUI(_ output: PreferenceSetUpOutput) {
        updateViewData(output)
        viewController.collectionView.reloadData()
    }

    func updateViewData(_ output: PreferenceSetUpOutput) {
        let preferenceCellList: [PreferenceCell] = [
            .launchAtLogin(viewData: SwitchCellViewData(
                switchState: output.launchAtLogin,
                title: LocalizedString(key: .preference_launch_at_login_title),
                description: LocalizedString(key: .preference_launch_at_login_description)
            )),
            .visibilityIcon(viewData: SwitchCellViewData(
                switchState: output.visibilityIcon,
                title: LocalizedString(key: .preference_display_icon_title),
                description: LocalizedString(key: .preference_display_icon_description)
            )),
            .openThisWindowAtFirst(viewData: SwitchCellViewData(
                switchState: output.openThisWindowAtFirst,
                title: LocalizedString(key: .preference_open_window_title),
                description: LocalizedString(key: .preference_open_window_description)
            ))
        ]
        viewController.viewData = .init(switchPreferences: preferenceCellList)
    }
}
