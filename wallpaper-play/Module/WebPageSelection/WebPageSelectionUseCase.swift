import Foundation
import Injectable

protocol WebPageSelectionUseCase {
    func initialSetUp()
    func setUpDescriptionPreview()
    func setUpPreview(for urlString: String)
    func setUpPreviewIfValidUrl(for urlString: String)
    func clearPreview()
    func setUpWallpaper(for urlString: String)
}

class WebPageSelectionInteractor: WebPageSelectionUseCase {
    private let presenter: WebPageSelectionPresenter
    private let wallpaperRequestService: WallpaperRequestService
    private let urlValidationService: UrlValidationService
    
    internal init(injector: Injectable = Injector.shared) {
        self.presenter = injector.build(WebPageSelectionPresenter.self)
        self.wallpaperRequestService = injector.build()
        self.urlValidationService = injector.build()
    }

    func initialSetUp() {
        if let path = Bundle.main.path(forResource: "copy_description_for_web", ofType: "html") {
            presenter.setPreview(url: URL(fileURLWithPath: path))
        }
    }

    func setUpDescriptionPreview() {
        if let path = Bundle.main.path(forResource: "copy_description_for_web", ofType: "html") {
            presenter.setPreview(url: URL(fileURLWithPath: path))
        }
    }

    func setUpPreview(for urlString: String) {
        if let url = urlValidationService.validate(string: urlString) {
            presenter.setPreview(url: url)
        } else {
            presenter.clearPreview()
            presenter.showAlert(message: LocalizedString(key: .error_invalid_url))
        }
    }

    func setUpPreviewIfValidUrl(for urlString: String) {
        if let url = urlValidationService.validate(string: urlString) {
            presenter.setPreview(url: url)
        }
    }

    func clearPreview() {
        presenter.clearPreview()
    }
    
    func setUpWallpaper(for urlString: String) {
        if let url = urlValidationService.validate(string: urlString) {
            wallpaperRequestService.requestWebWallpaper(url: url)
        } else {
            presenter.showAlert(message: LocalizedString(key: .error_invalid_preview))
        }
    }
}
