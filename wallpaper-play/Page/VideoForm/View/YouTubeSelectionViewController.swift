import Cocoa
import WebKit

class YouTubeSelectionViewController: NSViewController {
    
    @IBOutlet weak var thumbnailImageView: AntialiasedImageView!
    @IBOutlet weak var youtubeLinkTextField: NSSearchField! {
        didSet {
            youtubeLinkTextField.delegate = self
        }
    }
    @IBOutlet weak var youtubeWrappingView: NSView!
    public var youtubeWebView: YoutubeWebView!
    @IBOutlet weak var wallpaperButton: NSButton!
    
    var action: YouTubeSelectionAction
    
    init(action: YouTubeSelectionAction) {
        self.action = action
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        youtubeWebView = .init(frame: .zero, configuration: .init())
        youtubeWrappingView.fitAllAnchor(youtubeWebView)
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        action.didTapConfirmButton(youtubeLink: youtubeLinkTextField.stringValue)
    }
    
    @IBAction func didTapWallpaperButton(_ sender: Any) {
        action.didTapWallpaperButton(youtubeLink: youtubeLinkTextField.stringValue, mute: true)
    }
}

extension YouTubeSelectionViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let urlString = youtubeLinkTextField.stringValue
            action.enteredYouTubeLink(urlString)
            return false
        } else if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            return false
        }
        return false
    }
}
