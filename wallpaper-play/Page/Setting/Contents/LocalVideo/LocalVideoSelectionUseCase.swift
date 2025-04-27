import AppKit
import Injectable

struct VideoConfigInput {
    let link: URL
    let mute: Bool
    let videoSize: VideoSize
    let backgroundColor: NSColor?
    let target: WallpaperDisplayTarget
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
        wallpaperRequestService.requestVideoWallpaper(
            video: VideoPlayRequest(
                url: input.link,
                mute: input.mute,
                videoSize: input.videoSize,
                backgroundColor: input.backgroundColor,
                target: input.target
            )
        )
    }
}
