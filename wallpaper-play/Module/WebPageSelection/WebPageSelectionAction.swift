import Foundation
import Injectable

protocol WebPageSelectionAction {
    func viewDidLoad()
    func viewDidDisapper()
    func onChangeSearchField(_ value: String)
    func didTapSetWallpaperButton(value: String)
    func enteredSearchField(value: String)
}

class WebPageSelectionActionImpl: WebPageSelectionAction {
    
    private let useCase: WebPageSelectionUseCase

    public init(injector: Injectable) {
        self.useCase = injector.build(WebPageSelectionUseCase.self)
    }
    
    func viewDidLoad() {}

    func viewDidDisapper() {
        useCase.clearPreview()
    }

    func onChangeSearchField(_ value: String) {
        useCase.setUpPreviewIfValidUrl(for: value)
    }

    func didTapSetWallpaperButton(value: String) {
        useCase.setUpWallpaper(for: value)
    }
    
    func enteredSearchField(value: String) {
        useCase.setUpPreview(for: value)
    }
}






