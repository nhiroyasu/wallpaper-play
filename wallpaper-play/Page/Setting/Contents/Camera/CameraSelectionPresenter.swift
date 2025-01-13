import Foundation
import AppKit
import AVFoundation
import Injectable

protocol CameraSelectionPresenter {
    func didTapSetWallpaperButton(selectedCamera: AVCaptureDevice, videoSize: VideoSize)
}

class CameraSelectionPresenterImpl: CameraSelectionPresenter {
    private let useCase: any CameraSelectionUseCase
    private let fileSelectionService: any FileSelectionManager
    private let alertManager: any AlertManager
    weak var output: (any CameraSelectionViewOutput)!

    init(
        useCase: any CameraSelectionUseCase,
        alertManager: any AlertManager,
        fileSelectionService: any FileSelectionManager
    ) {
        self.useCase = useCase
        self.alertManager = alertManager
        self.fileSelectionService = fileSelectionService
    }

    func didTapSetWallpaperButton(selectedCamera: AVCaptureDevice, videoSize: VideoSize) {
        useCase.requestSettingWallpaper(selectedCamera.uniqueID, videoSize: videoSize)
    }
}
