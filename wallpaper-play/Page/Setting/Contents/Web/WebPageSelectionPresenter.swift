import Foundation
import Injectable

protocol WebPageSelectionPresenter {
    func onChangeSearchField(_ value: String)
    func didTapSetWallpaperButton(value: String)
    func enteredSearchField(value: String)
}

class WebPageSelectionPresenterImpl: WebPageSelectionPresenter {
    private let useCase: WebPageSelectionUseCase
    private let alertManager: AlertManager
    weak var output: WebPageSelectionViewOutput!

    init(useCase: WebPageSelectionUseCase, alertManager: AlertManager) {
        self.useCase = useCase
        self.alertManager = alertManager
    }

    func onChangeSearchField(_ value: String) {
        if let url = useCase.validateUrl(string: value) {
            output.setPreview(url: url)
        }
    }

    func didTapSetWallpaperButton(value: String) {
        if let url = useCase.validateUrl(string: value) {
            useCase.requestWallpaper(url: url)
        } else {
            alertManager.warning(msg: LocalizedString(key: .error_invalid_preview), completionHandler: {})
        }
    }

    func enteredSearchField(value: String) {
        if let url = useCase.validateUrl(string: value) {
            output.setPreview(url: url)
        } else {
            output.clearPreview()
            alertManager.warning(msg: LocalizedString(key: .error_invalid_url), completionHandler: {})
        }
    }
}
