import Foundation
import AppKit
import AVFoundation
import Injectable

protocol CameraSelectionPresenter {
    func didTapSetWallpaperButton(selectedCamera: AVCaptureDevice, videoSize: VideoSize, displayTargetMenu: DisplayTargetMenu)
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

    func didTapSetWallpaperButton(selectedCamera: AVCaptureDevice, videoSize: VideoSize, displayTargetMenu: DisplayTargetMenu) {
        let target: WallpaperDisplayTarget
        switch displayTargetMenu {
        case .allMonitors:
            target = .sameOnAllMonitors
        case .screen(let nSScreen):
            target = .specificMonitor(screen: nSScreen)
        }

        useCase.requestSettingWallpaper(selectedCamera.uniqueID, videoSize: videoSize, target: target)
    }
}
