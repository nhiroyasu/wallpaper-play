import Injectable
import AVFoundation

protocol CameraSelectionUseCase {
    func requestSettingWallpaper(_ deviceId: String, videoSize: VideoSize, target: WallpaperDisplayTarget)
}

class CameraSelectionInteractor: CameraSelectionUseCase {

    private let wallpaperRequestService: any WallpaperRequestService

    init(wallpaperRequestService: any WallpaperRequestService) {
        self.wallpaperRequestService = wallpaperRequestService
    }

    func requestSettingWallpaper(_ deviceId: String, videoSize: VideoSize, target: WallpaperDisplayTarget) {
        wallpaperRequestService.requestCameraWallpaper(
            camera: CameraPlayRequest(deviceId: deviceId, videoSize: videoSize, target: target)
        )
    }
}
