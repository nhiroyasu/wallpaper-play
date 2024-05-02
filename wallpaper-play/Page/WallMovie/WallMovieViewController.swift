import Cocoa

class WallMovieViewController: NSViewController {
    
    var webView: YoutubeWebView!
    var videoView: VideoView!
    let action: WallMovieAction
    private let wallpaperSize: NSSize

    init(wallpaperSize: NSSize, action: WallMovieAction) {
        self.wallpaperSize = wallpaperSize
        self.action = action
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
        action.viewDidLoad()
    }
    
    override func viewWillDisappear() {
        super.viewDidAppear()
        action.viewWillDisappear()
    }
  
    override var representedObject: Any? {
        didSet {
        }
    }
}

