import Foundation
import WebKit
import AVFoundation
import Injectable

struct VideoPlayValue {
    let urls: [URL]
    let mute: Bool
    let videoSize: VideoSize
}

enum WallpaperKind {
    case video(value: VideoPlayValue)
    case youtube(url: URL)
    case web(url: URL)
    case none
}

protocol WallMoviePresenter {
    func initViews(screenFrame: NSRect)
    func display(openType: WallpaperKind)
}

class WallMoviePresenterImpl: NSObject, WallMoviePresenter {
    private let avManager: AVPlayerManager
    private let youtubeContentService: YouTubeContentsService
    var output: WallMovieViewController!

    init(injector: Injectable) {
        self.avManager = injector.build(AVPlayerManager.self)
        self.youtubeContentService = injector.build(YouTubeContentsService.self)
    }

    func initViews(screenFrame: NSRect) {
        output.videoView = .init(frame: .init(origin: .zero, size: screenFrame.size))
        output.webView = .init(frame: .zero, configuration: .init())
        output.view.fitAllAnchor(output.webView)
        output.view.fitAllAnchor(output.videoView)
        output.webView.uiDelegate = self
        output.webView.navigationDelegate = self
    }
    
    func display(openType: WallpaperKind) {
        switch openType {
        case .video(let value):
            resetVideos()
            output.videoView.setFrameSize(output.view.window!.frame.size)
            output.videoView.isHidden = false
            let player = avManager.set(value.urls)
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
        case .youtube(let url):
            resetVideos()
            output.webView.isHidden = false
            output.webView.load(URLRequest(url: url))
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
