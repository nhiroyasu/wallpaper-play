import Foundation
import Injectable

protocol YouTubeSelectionAction {
    func enteredYouTubeLink(_ value: String)
    func didTapConfirmButton(youtubeLink: String)
    func didTapWallpaperButton(youtubeLink: String, mute: Bool)
}

class YouTubeSelectionActionImpl: YouTubeSelectionAction {
    
    private let useCase: YouTubeSelectionUseCase
    
    public init(injector: Injectable = Injector.shared) {
        self.useCase = injector.build(YouTubeSelectionUseCase.self)
    }
    
    func enteredYouTubeLink(_ value: String) {
        useCase.confirm(value)
    }
    
    func didTapConfirmButton(youtubeLink: String) {
        useCase.confirm(youtubeLink)
    }
    
    func didTapWallpaperButton(youtubeLink: String, mute: Bool) {
        useCase.requestSettingWallpaper(youtubeLink: youtubeLink, mute: mute)
    }
}
