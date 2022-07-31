import Foundation
import Injectable

protocol WebPageSelectionUseCase {
    func setUpPreview(for urlString: String)
    func setUpWallpaper(for url: URL)
    func showError(message: String)
}

class WebPageSelectionInteractor: WebPageSelectionUseCase {
    
    private let presenter: WebPageSelectionPresenter
    private let urlValidationService: UrlValidationService
    
    internal init(injector: Injectable = Injector.shared) {
        self.presenter = injector.build(WebPageSelectionPresenter.self)
        self.urlValidationService = injector.build()
    }
    
    func setUpPreview(for urlString: String) {
        if let url = urlValidationService.validate(string: urlString) {
            presenter.setPreview(url: url)
        } else {
            presenter.clearPreview()
            presenter.showAlert(message: LocalizedString(key: .error_invalid_url))
        }
    }
    
    func setUpWallpaper(for url: URL) {
        presenter.setUpWallpaper(for: url)
    }
    
    func showError(message: String) {
        presenter.showAlert(message: message)
    }
}
