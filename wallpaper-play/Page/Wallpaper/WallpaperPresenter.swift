import AppKit
import Injectable

struct VideoPlayValue {
    let url: URL
    let mute: Bool
    let videoSize: VideoSize
    let backgroundColor: NSColor?
}

struct YouTubePlayValue {
    let videoId: String
    let isMute: Bool
}

struct WebPlayValue {
    let url: URL
    let arrowOperation: Bool
}

enum WallpaperKind {
    case video(value: VideoPlayValue)
    case youtube(videoId: String, isMute: Bool)
    case web(url: URL, arrowOperation: Bool)
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
                .video(
                    value.url,
                    videoSize: value.videoSize,
                    mute: value.mute,
                    backgroundColor: value.backgroundColor
                )
        case .youtube(let videoId, let isMute):
            if let url = youtubeContentService.buildFullIframeUrl(id: videoId, mute: isMute) {
                .youtube(url)
            } else {
                .none
            }
        case .web(let url, let arrowOperation):
            .web(url, arrowOperation: arrowOperation)
        case .none:
            .none
        }
        output.display(displayType)
    }
}
