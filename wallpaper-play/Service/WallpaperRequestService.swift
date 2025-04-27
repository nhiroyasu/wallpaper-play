import Foundation
import Injectable

protocol WallpaperRequestService {
    func requestVideoWallpaper(video: VideoPlayRequest)
    func requestYoutubeWallpaper(youtube: YouTubePlayRequest)
    func requestWebWallpaper(web: WebPlayRequest)
    func requestCameraWallpaper(camera: CameraPlayRequest)
}

class WallpaperRequestServiceImpl: WallpaperRequestService {
    private let notificationManager: any NotificationManager

    init(injector: any Injectable) {
        self.notificationManager = injector.build()
    }

    func requestVideoWallpaper(video: VideoPlayRequest) {
        notificationManager.push(name: .requestVideo, param: video)
    }
    
    func requestYoutubeWallpaper(youtube: YouTubePlayRequest) {
        notificationManager.push(name: .requestYouTube, param: youtube)
    }
    
    func requestWebWallpaper(web: WebPlayRequest) {
        notificationManager.push(name: .requestWebPage, param: web)
    }

    func requestCameraWallpaper(camera: CameraPlayRequest) {
        notificationManager.push(name: .requestCamera, param: camera)
    }
}
