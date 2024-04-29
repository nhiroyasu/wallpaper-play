import Foundation
import WebKit
import AVFoundation
import Injectable

struct VideoPlayValue {
    let url: URL
    let mute: Bool
    let videoSize: VideoSize
}

enum WallpaperKind {
    case video(value: VideoPlayValue)
    case youtube(videoId: String, isMute: Bool)
    case web(url: URL)
    case none
}

protocol WallMoviePresenter {
    func initViews()
    func display(openType: WallpaperKind)
}

class WallMoviePresenterImpl: NSObject, WallMoviePresenter {
    private let avManager: AVPlayerManager
    private let youtubeContentService: YouTubeContentsService
    weak var output: WallMovieViewController!

    init(injector: Injectable) {
        self.avManager = injector.build(AVPlayerManager.self)
        self.youtubeContentService = injector.build(YouTubeContentsService.self)
    }

    func initViews() {
        output.webView.uiDelegate = self
        output.webView.navigationDelegate = self
    }
    
    func display(openType: WallpaperKind) {
        switch openType {
        case .video(let value):
            resetVideos()
            output.videoView.setFrameSize(output.view.window!.frame.size)
            output.videoView.isHidden = false
            let player = avManager.set([value.url])
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = value.videoSize.videoGravity
            output.videoView.setPlayerLayer(layer)
            do {
                try avManager.mute(value.mute)
                try avManager.loop(type: .listLoop)
                try avManager.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        case .youtube(let videoId, let isMute):
            resetVideos()
            output.webView.isHidden = false
            if let url = youtubeContentService.buildFullIframeUrl(id: videoId, mute: isMute) {
                output.webView.load(URLRequest(url: url))
            } else {
                assertionFailure("Failed to build YouTube URL")
            }
        case .web(let url):
            resetVideos()
            output.webView.isHidden = false
            output.webView.load(URLRequest(url: url))
        case .none:
            output.videoView.isHidden = true
            output.webView.isHidden = true
        }
    }
    
    private func resetVideos() {
        removeVideo()
        removeYouTubeView()
    }
    
    private func removeVideo() {
        output.videoView.isHidden = true
        output.videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        avManager.clear()
    }
    
    private func removeYouTubeView() {
        output.webView.loadHTMLString("", baseURL: nil)
        output.webView.isHidden = true
    }
}

extension WallMoviePresenterImpl: WKUIDelegate, WKNavigationDelegate {
}
