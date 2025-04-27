import AppKit
import AVFoundation
import Injectable

enum WallpaperKind {
    case video(url: URL, mute: Bool, videoSize: VideoSize, backgroundColor: NSColor?)
    case youtube(videoId: String, isMute: Bool, videoSize: VideoSize)
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
        case .video(let url, let mute, let videoSize, let backgroundColor):
                .video(url, videoSize: videoSize, mute: mute, backgroundColor: backgroundColor)
        case .youtube(let videoId, let isMute, let videoSize):
            if let url = youtubeContentService.buildFullIframeUrl(id: videoId, mute: isMute) {
                .youtube(url, videoSize: videoSize)
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
