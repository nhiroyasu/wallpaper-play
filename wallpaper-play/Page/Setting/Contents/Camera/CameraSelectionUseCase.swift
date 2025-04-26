import Injectable
import AVFoundation

protocol CameraSelectionUseCase {
    func requestSettingWallpaper(_ deviceId: String, videoSize: VideoSize)
}

class CameraSelectionInteractor: CameraSelectionUseCase {

    private let wallpaperRequestService: any WallpaperRequestService

    init(wallpaperRequestService: any WallpaperRequestService) {
        self.wallpaperRequestService = wallpaperRequestService
    }

    func requestSettingWallpaper(_ deviceId: String, videoSize: VideoSize) {
        wallpaperRequestService.requestCameraWallpaper(
            camera: CameraPlayRequest(deviceId: deviceId, videoSize: videoSize)
        )
    }
}
