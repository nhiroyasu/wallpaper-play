import Foundation
import Injectable

protocol YouTubeSelectionPresenter {
    func viewDidLoad()
    func onChangeSearchField(_ value: String)
    func enteredYouTubeLink(_ value: String)
    func didTapWallpaperButton(youtubeLink: String, mute: Bool, videoSize: VideoSize)
}

class YouTubeSelectionPresenterImpl: YouTubeSelectionPresenter {
    private let useCase: any YouTubeSelectionUseCase
    private let alertService: any AlertManager
    weak var output: (any YouTubeSelectionViewOutput)!

    init(
        useCase: any YouTubeSelectionUseCase,
        alertService: any AlertManager
    ) {
        self.useCase = useCase
        self.alertService = alertService
    }

    func viewDidLoad() {
        output.setEnableWallpaperButton(false)
    }

    func onChangeSearchField(_ value: String) {
        guard let iframeUrl = useCase.retrieveIFrameUrl(from: value) else {
            output.setEnableWallpaperButton(false)
            return
        }
        output.updatePreview(url: iframeUrl)
        output.setEnableWallpaperButton(true)
        if let thumbnailUrl = useCase.retrieveThumbnailUrl(from: value) {
            output.updateThumbnail(url: thumbnailUrl)
        }
    }

    func enteredYouTubeLink(_ value: String) {
        guard let iframeUrl = useCase.retrieveIFrameUrl(from: value) else {
            alertService.warning(msg: LocalizedString(key: .error_invalid_youtube_url), completionHandler: {})
            output.setEnableWallpaperButton(false)
            output.clearPreview()
            output.clearThumbnail()
            return
        }
        output.updatePreview(url: iframeUrl)
        output.setEnableWallpaperButton(true)
        if let thumbnailUrl = useCase.retrieveThumbnailUrl(from: value) {
            output.updateThumbnail(url: thumbnailUrl)
        }
    }

    func didTapWallpaperButton(youtubeLink: String, mute: Bool, videoSize: VideoSize) {
        guard let videoId = useCase.retrieveVideoId(from: youtubeLink) else {
            alertService.warning(msg: LocalizedString(key: .error_invalid_youtube_url), completionHandler: {})
            return
        }
        useCase.requestWallpaper(videoId: videoId, mute: mute, videoSize: videoSize)
    }
}
