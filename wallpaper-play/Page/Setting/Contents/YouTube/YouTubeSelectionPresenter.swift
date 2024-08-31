import Foundation
import Injectable

protocol YouTubeSelectionPresenter {
    func onChangeSearchField(_ value: String)
    func enteredYouTubeLink(_ value: String)
    func didTapWallpaperButton(youtubeLink: String, mute: Bool)
}

class YouTubeSelectionPresenterImpl: YouTubeSelectionPresenter {
    private let useCase: YouTubeSelectionUseCase
    private let alertService: AlertManager
    weak var output: YouTubeSelectionViewOutput!

    init(
        useCase: YouTubeSelectionUseCase,
        alertService: AlertManager
    ) {
        self.useCase = useCase
        self.alertService = alertService
    }

    func onChangeSearchField(_ value: String) {
        updatePreviewIfNeeded(youtubeLink: value)
    }

    func enteredYouTubeLink(_ value: String) {
        updatePreviewIfNeeded(youtubeLink: value)
    }

    func didTapWallpaperButton(youtubeLink: String, mute: Bool) {
        guard let videoId = useCase.retrieveVideoId(from: youtubeLink) else {
            alertService.warning(msg: LocalizedString(key: .error_invalid_youtube_url), completionHandler: {})
            return
        }
        useCase.requestWallpaper(videoId: videoId, mute: mute)
    }

    // MARK: - internal

    private func updatePreviewIfNeeded(youtubeLink: String) {
        guard let iframeUrl = useCase.retrieveIFrameUrl(from: youtubeLink) else {
            return
        }

        output.updatePreview(url: iframeUrl)
        output.setEnableWallpaperButton(true)
        if let thumbnailUrl = useCase.retrieveThumbnailUrl(from: youtubeLink) {
            output.updateThumbnail(url: thumbnailUrl)
        }
    }
}
