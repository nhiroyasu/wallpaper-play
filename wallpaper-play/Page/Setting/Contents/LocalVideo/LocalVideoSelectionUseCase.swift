import Foundation
import Injectable

struct VideoConfigInput {
    let link: URL
    let mute: Bool
    let videoSize: VideoSize
}

typealias VideoConfigOutput = VideoConfigInput

protocol LocalVideoSelectionUseCase {
    func requestSettingWallpaper(_ input: VideoConfigInput)
}

class LocalVideoSelectionInteractor: LocalVideoSelectionUseCase {
    
    private let wallpaperRequestService: any WallpaperRequestService

    init(wallpaperRequestService: any WallpaperRequestService) {
        self.wallpaperRequestService = wallpaperRequestService
    }

    func requestSettingWallpaper(_ input: VideoConfigInput) {
        wallpaperRequestService.requestVideoWallpaper(video: VideoPlayValue(url: input.link, mute: input.mute, videoSize: input.videoSize))
    }
}
