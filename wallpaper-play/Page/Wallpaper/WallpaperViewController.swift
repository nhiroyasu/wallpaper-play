import Cocoa
import AVFoundation
import WebKit

protocol WallpaperViewOutput {
    func display(_ displayType: WallpaperDisplayType)
}

class WallpaperViewController: NSViewController {
    
    var webView: YoutubeWebView!
    var videoView: VideoView!
    private let wallpaperSize: NSSize
    private let avManager: AVPlayerManager
    private let presenter: WallpaperPresenter

    init(
        wallpaperSize: NSSize,
        presenter: WallpaperPresenter,
        avManager: AVPlayerManager
    ) {
        self.wallpaperSize = wallpaperSize
        self.presenter = presenter
        self.avManager = avManager
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not call")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoView = .init(frame: .init(origin: .zero, size: wallpaperSize))
        webView = .init(frame: .zero, configuration: .init())
        view.fitAllAnchor(webView)
        view.fitAllAnchor(videoView)

        presenter.viewDidLoad()
    }
}

extension WallpaperViewController: WallpaperViewOutput {
    func display(_ displayType: WallpaperDisplayType) {
        switch displayType {
        case .video(let url, let videoSize, let mute):
            allClear()
            videoView.isHidden = false
            let player = avManager.set([url])
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = videoSize.videoGravity
            videoView.setPlayerLayer(layer)
            do {
                try avManager.mute(mute)
                try avManager.loop(type: .listLoop)
                try avManager.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        case .youtube(let url):
            allClear()
            webView.isHidden = false
            webView.load(URLRequest(url: url))
        case .web(let url):
            allClear()
            webView.isHidden = false
            webView.load(URLRequest(url: url))
        case .none:
            allClear()
        }
    }
}

// MARK: - internal

extension WallpaperViewController {
    private func allClear() {
        removeVideo()
        removeYouTubeView()
    }

    private func removeVideo() {
        videoView.isHidden = true
        videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        avManager.clear()
    }

    private func removeYouTubeView() {
        webView.loadHTMLString("", baseURL: nil)
        webView.isHidden = true
    }
}

enum WallpaperDisplayType {
    case video(URL, videoSize: VideoSize, mute: Bool)
    case youtube(URL)
    case web(URL)
    case none
}