import Foundation
import Injectable

protocol WallpaperRequestService {
    func requestVideoWallpaper(video: VideoPlayValue)
    func requestYoutubeWallpaper(youtube: YouTubePlayValue)
    func requestWebWallpaper(url: URL)
}

class WallpaperRequestServiceImpl: WallpaperRequestService {
    private let notificationManager: any NotificationManager

    init(injector: any Injectable) {
        self.notificationManager = injector.build()
    }

    func requestVideoWallpaper(video: VideoPlayValue) {
        notificationManager.push(name: .requestVideo, param: video)
    }
    
    func requestYoutubeWallpaper(youtube: YouTubePlayValue) {
        notificationManager.push(name: .requestYouTube, param: youtube)
    }
    
    func requestWebWallpaper(url: URL) {
        notificationManager.push(name: .requestWebPage, param: url)
    }
}
