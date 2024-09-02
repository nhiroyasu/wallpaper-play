import Foundation
import AppKit
import AVFoundation
import Injectable

protocol LocalVideoSelectionPresenter {
    func didTapVideoSelectionButton()
    func didTapWallpaperButton(videoLink: String, mute: Bool, videoSize: VideoSize)
}

class LocalVideoSelectionPresenterImpl: LocalVideoSelectionPresenter {
    private let useCase: any LocalVideoSelectionUseCase
    private let fileSelectionService: any FileSelectionManager
    private let alertManager: any AlertManager
    weak var output: (any LocalVideoSelectionViewOutput)!

    init(
        useCase: any LocalVideoSelectionUseCase,
        alertManager: any AlertManager,
        fileSelectionService: any FileSelectionManager
    ) {
        self.useCase = useCase
        self.alertManager = alertManager
        self.fileSelectionService = fileSelectionService
    }

    func didTapVideoSelectionButton() {
        if let url = fileSelectionService.open(fileType: .movie) {
            output.setThumbnail(videoUrl: url)
            output.setPreview(videoUrl: url)
            output.setFilePath(videoUrl: url)
        }
    }

    func didTapWallpaperButton(videoLink: String, mute: Bool, videoSize: VideoSize) {
        if let url = URL(string: videoLink) {
            let input = VideoConfigInput(link: url, mute: mute, videoSize: videoSize)
            useCase.requestSettingWallpaper(input)
        } else {
            alertManager.warning(msg: LocalizedString(key: .error_invalid_video), completionHandler: {})
        }
    }
}
