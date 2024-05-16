import Foundation
import Injectable

struct VideoConfigInput {
    let link: URL
    let mute: Bool
    let videoSize: VideoSize
}

typealias VideoConfigOutput = VideoConfigInput

protocol LocalVideoSelectionUseCase {
    func setUp()
    func confirmVideo(url: URL)
    func clearPreview()
    func requestSettingWallpaper(_ input: VideoConfigInput)
    func videoLoadingError()
}

class LocalVideoSelectionInteractor: LocalVideoSelectionUseCase {
    
    private let wallpaperRequestService: WallpaperRequestService
    private let presenter: LocalVideoSelectionPresenter
    
    internal init(injector: Injectable = Injector.shared) {
        self.wallpaperRequestService = injector.build()
        self.presenter = injector.build(LocalVideoSelectionPresenter.self)
    }
    
    func setUp() {
        presenter.initViews()
    }
    
    func confirmVideo(url: URL) {
        presenter.setThumbnail(videoUrl: url)
        presenter.setPreview(videoUrl: url)
        presenter.setFilePath(videoUrl: url)
    }
    
    func clearPreview() {
        presenter.removePreview()
    }
    
    func requestSettingWallpaper(_ input: VideoConfigInput) {
        wallpaperRequestService.requestVideoWallpaper(video: VideoPlayValue(url: input.link, mute: input.mute, videoSize: input.videoSize))
    }
    
    func videoLoadingError() {
        presenter.showError(msg: LocalizedString(key: .error_invalid_video))
    }
}
