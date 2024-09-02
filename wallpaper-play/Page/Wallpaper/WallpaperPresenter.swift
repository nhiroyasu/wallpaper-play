import Foundation
import Injectable

struct VideoPlayValue {
    let url: URL
    let mute: Bool
    let videoSize: VideoSize
}

struct YouTubePlayValue {
    let videoId: String
    let isMute: Bool
}

enum WallpaperKind {
    case video(value: VideoPlayValue)
    case youtube(videoId: String, isMute: Bool)
    case web(url: URL)
    case none
}

protocol WallpaperPresenter {
    func viewDidLoad()
}

class WallpaperPresenterImpl: NSObject, WallpaperPresenter {
    private let youtubeContentService: any YouTubeContentsService
    private let wallpaperKind: WallpaperKind
    weak var output: WallpaperViewController!

    init(wallpaperKind: WallpaperKind, youtubeContentService: any YouTubeContentsService) {
        self.wallpaperKind = wallpaperKind
        self.youtubeContentService = youtubeContentService
    }

    func viewDidLoad() {
        let displayType: WallpaperDisplayType = switch wallpaperKind {
        case .video(let value):
            .video(value.url, videoSize: value.videoSize, mute: value.mute)
        case .youtube(let videoId, let isMute):
            if let url = youtubeContentService.buildFullIframeUrl(id: videoId, mute: isMute) {
                .youtube(url)
            } else {
                .none
            }
        case .web(let url):
            .web(url)
        case .none:
            .none
        }
        output.display(displayType)
    }
}
