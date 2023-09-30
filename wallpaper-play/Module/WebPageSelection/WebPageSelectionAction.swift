import Foundation
import Injectable

protocol WebPageSelectionAction {
    func viewDidLoad()
    func viewDidDisapper()
    func didTapConfirmButton()
    func didTapSetWallpaperButton()
    func enteredSearchField()
}

class WebPageSelectionActionImpl: WebPageSelectionAction {
    
    private let useCase: WebPageSelectionUseCase
    private let state: WebPageSelectionState
    
    public init(injector: Injectable, state: WebPageSelectionState) {
        self.useCase = injector.build(WebPageSelectionUseCase.self)
        self.state = state
    }
    
    func viewDidLoad() {}

    func viewDidDisapper() {
        useCase.clearPreview()
    }
    
    func didTapConfirmButton() {
        useCase.setUpPreview(for: state.input)
    }
    
    func didTapSetWallpaperButton() {
        if let url = state.previewUrl {
            useCase.setUpWallpaper(for: url)
        } else {
            useCase.showError(message: LocalizedString(key: .error_invalid_preview))
        }
    }
    
    func enteredSearchField() {
        useCase.setUpPreview(for: state.input)
    }
}






