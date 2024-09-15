import Cocoa
import AVFoundation
import WebKit

protocol WallpaperViewOutput {
    func display(_ displayType: WallpaperDisplayType)
}

class WallpaperViewController: NSViewController {

    var webView: WallpaperWebView!
    var youtubeView: WallpaperWebView!
    var videoView: VideoView!
    private let wallpaperSize: NSSize
    private let avManager: any AVPlayerManager
    private let presenter: any WallpaperPresenter

    init(
        wallpaperSize: NSSize,
        presenter: any WallpaperPresenter,
        avManager: any AVPlayerManager
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
        youtubeView = .init(frame: .zero, configuration: .youtubeWallpaper)
        webView = .init(frame: .zero, configuration: .webWallpaper)
        view.fitAllAnchor(youtubeView)
        view.fitAllAnchor(webView)
        view.fitAllAnchor(videoView)

        presenter.viewDidLoad()
    }
}

extension WallpaperViewController: WallpaperViewOutput {
    func display(_ displayType: WallpaperDisplayType) {
        switch displayType {
        case .video(let url, let videoSize, let mute, let backgroundColor):
            allClear()
            videoView.isHidden = false
            let player = avManager.set([url])
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = videoSize.videoGravity
            videoView.setPlayerLayer(layer)
            videoView.setBackgroundColor(backgroundColor)
            do {
                try avManager.mute(mute)
                try avManager.loop(type: .listLoop)
                try avManager.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        case .youtube(let url):
            allClear()
            youtubeView.isHidden = false
            youtubeView.load(URLRequest(url: url))
        case .web(let url, let arrowOperation):
            allClear()
            webView.isHidden = false
            webView.load(URLRequest(url: url))
            webView.setArrowOperation(arrowOperation)
        case .none:
            allClear()
        }
    }
}

// MARK: - internal

extension WallpaperViewController {
    private func allClear() {
        removeVideo()
        removeYoutubeView()
        removeWebView()
    }

    private func removeVideo() {
        videoView.isHidden = true
        videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        avManager.clear()
    }

    private func removeYoutubeView() {
        youtubeView.loadHTMLString("", baseURL: nil)
        youtubeView.setArrowOperation(false)
        youtubeView.isHidden = true
    }

    private func removeWebView() {
        webView.loadHTMLString("", baseURL: nil)
        webView.setArrowOperation(false)
        webView.isHidden = true
    }
}

enum WallpaperDisplayType {
    case video(URL, videoSize: VideoSize, mute: Bool, backgroundColor: NSColor?)
    case youtube(URL)
    case web(URL, arrowOperation: Bool)
    case none
}
