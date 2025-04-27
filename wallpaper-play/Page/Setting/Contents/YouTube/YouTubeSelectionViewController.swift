import Cocoa
import WebKit
import Combine

protocol YouTubeSelectionViewOutput: AnyObject {
    func updatePreview(url: URL)
    func updateThumbnail(url: URL)
    func clearPreview()
    func clearThumbnail()
    func setEnableWallpaperButton(_ value: Bool)
}

class YouTubeSelectionViewController: NSViewController {
    @IBOutlet weak var thumbnailImageView: AntialiasedImageView!
    @IBOutlet weak var youtubeLinkTextField: NSSearchField! {
        didSet {
            youtubeLinkTextField.delegate = self
        }
    }
    @IBOutlet weak var youtubeWrappingView: NSView!
    @IBOutlet weak var videoSizePopUpButton: NSPopUpButton! {
        didSet {
            videoSizePopUpButton.menu?.items = VideoSize.allCases.map {
                .init(title: $0.text, action: nil, keyEquivalent: "")
            }
            videoSizePopUpButton.selectItem(at: 0)
        }
    }
    @IBOutlet weak var displayTargetPopUpButton: NSPopUpButton!
    @IBOutlet weak var wallpaperButton: NSButton!
    @IBOutlet weak var muteToggleButton: NSButton!
    public var youtubeWebView: WallpaperWebView!
    private let presenter: any YouTubeSelectionPresenter
    private let displayTargetMenu: [DisplayTargetMenu]

    init(presenter: any YouTubeSelectionPresenter) {
        self.presenter = presenter
        self.displayTargetMenu = [.allMonitors] + NSScreen.screens.map { .screen($0) }
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeWebView = .init(frame: .zero, configuration: .youtubeWallpaper(videoSize: .aspectFit))
        youtubeWrappingView.fitAllAnchor(youtubeWebView)
        if let path = Bundle.main.path(forResource: "copy_description_for_youtube", ofType: "html") {
            updatePreview(url: URL(fileURLWithPath: path))
        }

        setUpDisplayTargetPopUpButton()

        presenter.viewDidLoad()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        if let path = Bundle.main.path(forResource: "copy_description_for_youtube", ofType: "html") {
            updatePreview(url: URL(fileURLWithPath: path))
        }
    }

    @IBAction func didTapWallpaperButton(_ sender: Any) {
        guard let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem) else {
            return
        }

        let displayTargetMenu = displayTargetMenu[displayTargetPopUpButton.indexOfSelectedItem]

        presenter.didTapWallpaperButton(
            youtubeLink: youtubeLinkTextField.stringValue,
            mute: muteToggleButton.state == .on,
            videoSize: videoSize,
            displayTargetMenu: displayTargetMenu
        )
    }

    private func setUpDisplayTargetPopUpButton() {
        displayTargetPopUpButton.menu?.items = displayTargetMenu.map { menu in
            NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
        }
    }
}

extension YouTubeSelectionViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            let urlString = youtubeLinkTextField.stringValue
            presenter.enteredYouTubeLink(urlString)
            return false
        }
        if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            return false
        }
        return false
    }

    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.userInfo?["NSFieldEditor"] as? NSTextView else { return }
        presenter.onChangeSearchField(textField.string)
    }
}

extension YouTubeSelectionViewController: YouTubeSelectionViewOutput {
    func updatePreview(url: URL) {
        youtubeWebView.load(URLRequest(url: url))
    }

    func updateThumbnail(url: URL) {
        thumbnailImageView.setImage(url: url)
    }

    func clearPreview() {
        if let path = Bundle.main.path(forResource: "copy_description_for_youtube", ofType: "html") {
            updatePreview(url: URL(fileURLWithPath: path))
        } else {
            youtubeWebView.loadHTMLString("", baseURL: nil)
        }
    }

    func clearThumbnail() {
        thumbnailImageView.image = nil
    }

    func setEnableWallpaperButton(_ value: Bool) {
        wallpaperButton.isEnabled = value
    }
}
