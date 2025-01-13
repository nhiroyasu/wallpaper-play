import AppKit
import AVFoundation
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

struct CameraPlayValue {
    let deviceId: String
    let videoSize: VideoSize
}

enum WallpaperKind {
    case video(value: VideoPlayValue)
    case youtube(videoId: String, isMute: Bool)
    case web(url: URL, arrowOperation: Bool)
    case camera(deviceId: String, videoSize: VideoSize)
    case unknown
}

protocol WallpaperPresenter {
    func viewDidLoad()
}

class WallpaperPresenterImpl: NSObject, WallpaperPresenter {
    private let youtubeContentService: any YouTubeContentsService
    private let cameraDeviceService: any CameraDeviceService
    private let wallpaperKind: WallpaperKind
    weak var output: WallpaperViewController!

    init(wallpaperKind: WallpaperKind, youtubeContentService: any YouTubeContentsService, cameraDeviceService: any CameraDeviceService) {
        self.wallpaperKind = wallpaperKind
        self.youtubeContentService = youtubeContentService
        self.cameraDeviceService = cameraDeviceService
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
        case .camera(let deviceId, let videoSize):
            if let camera = cameraDeviceService.fetchDevice(deviceId: deviceId) {
                .camera(captureDevice: camera, videoSize: videoSize)
            } else {
                .none
            }
        case .unknown:
            .none
        }
        output.display(displayType)
    }
}
