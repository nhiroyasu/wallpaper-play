import Cocoa

protocol WebPageSelectionViewOutput: AnyObject {
    func setPreview(url: URL)
    func clearPreview()
}

class WebPageSelectionViewController: NSViewController {

    // MARK: - Views
    @IBOutlet weak var urlSearchField: NSSearchField! {
        didSet {
            urlSearchField.delegate = self
        }
    }
    @IBOutlet weak var wrapView: NSView!
    @IBOutlet weak var setWallpaperButton: NSButton!
    public var previewWebView: YoutubeWebView!
    private let presenter: WebPageSelectionPresenter

    // MARK: - Methods
    init(presenter: WebPageSelectionPresenter) {
        self.presenter = presenter
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewWebView = .init(frame: .zero, configuration: .init())
        wrapView.fitAllAnchor(previewWebView)
        if let path = Bundle.main.path(forResource: "copy_description_for_web", ofType: "html") {
            setPreview(url: URL(fileURLWithPath: path))
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        clearPreview()
    }
    
    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        presenter.didTapSetWallpaperButton(value: urlSearchField.stringValue)
    }
}

extension WebPageSelectionViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            presenter.enteredSearchField(value: urlSearchField.stringValue)
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

extension WebPageSelectionViewController: WebPageSelectionViewOutput {
    func setPreview(url: URL) {
        previewWebView.load(URLRequest(url: url))
    }

    func clearPreview() {
        if let path = Bundle.main.path(forResource: "copy_description_for_web", ofType: "html") {
            setPreview(url: URL(fileURLWithPath: path))
        } else {
            previewWebView.loadHTMLString("", baseURL: nil)
        }
    }
}
