import Cocoa
import WebKit
import Combine

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
    @IBOutlet weak var muteToggleButton: NSButton!

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
        action.viewDidLoad()
    }

    @IBAction func didTapWallpaperButton(_ sender: Any) {
        action.didTapWallpaperButton(youtubeLink: youtubeLinkTextField.stringValue, mute: isMute())
    }

    private func isMute() -> Bool {
        muteToggleButton.state == .on
    }
}

extension YouTubeSelectionViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let urlString = youtubeLinkTextField.stringValue
            action.enteredYouTubeLink(urlString)
            return false
        }
        if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            return false
        }
        return false
    }

    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.userInfo?["NSFieldEditor"] as? NSTextView else { return }
        action.onChangeSearchField(textField.string)
    }
}
