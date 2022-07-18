import Cocoa

class WallMovieViewController: NSViewController {
    
    var webView: YoutubeWebView!
    var videoView: VideoView!
    let action: WallMovieAction
    private let screenFrame: NSRect
    
    init(screenFrame: NSRect, action: WallMovieAction) {
        self.screenFrame = screenFrame
        self.action = action
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not call")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        action.viewDidLoad(screenFrame: screenFrame)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // TODO: ここで動画再生
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

