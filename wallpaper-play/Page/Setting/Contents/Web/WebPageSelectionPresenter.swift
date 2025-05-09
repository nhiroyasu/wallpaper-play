import Foundation
import Injectable

protocol WebPageSelectionPresenter {
    func viewDidLoad()
    func onChangeSearchField(_ value: String)
    func didTapSetWallpaperButton(value: String, arrowOperation: Bool, displayTargetMenu: DisplayTargetMenu)
    func enteredSearchField(value: String)
}

class WebPageSelectionPresenterImpl: WebPageSelectionPresenter {
    private let useCase: any WebPageSelectionUseCase
    private let alertManager: any AlertManager
    weak var output: (any WebPageSelectionViewOutput)!

    init(useCase: any WebPageSelectionUseCase, alertManager: any AlertManager) {
        self.useCase = useCase
        self.alertManager = alertManager
    }

    func viewDidLoad() {
        output.setEnableWallpaperButton(false)
    }

    func onChangeSearchField(_ value: String) {
        if let url = useCase.validateUrl(string: value) {
            output.setPreview(url: url)
            output.setEnableWallpaperButton(true)
        } else {
            output.setEnableWallpaperButton(false)
        }
    }

    func didTapSetWallpaperButton(value: String, arrowOperation: Bool, displayTargetMenu: DisplayTargetMenu) {
        if let url = useCase.validateUrl(string: value) {
            let target: WallpaperDisplayTarget
            switch displayTargetMenu {
            case .allMonitors:
                target = .sameOnAllMonitors
            case .screen(let nSScreen):
                target = .specificMonitor(screen: nSScreen)
            }

            useCase.requestWallpaper(url: url, arrowOperation: arrowOperation, target: target)
        } else {
            alertManager.warning(msg: LocalizedString(key: .error_invalid_preview), completionHandler: {})
        }
    }

    func enteredSearchField(value: String) {
        if let url = useCase.validateUrl(string: value) {
            output.setPreview(url: url)
            output.setEnableWallpaperButton(true)
        } else {
            alertManager.warning(msg: LocalizedString(key: .error_invalid_url), completionHandler: {})
            output.setEnableWallpaperButton(false)
            output.clearPreview()
        }
    }
}
