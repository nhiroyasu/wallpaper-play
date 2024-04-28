import Cocoa

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
    
    // MARK: - Variables
    var action: WebPageSelectionAction
    var state: WebPageSelectionState
    private var inputObservation: NSKeyValueObservation?
    private var previewUrlObservation: NSKeyValueObservation?
    private var isEnableSetWallpaperButtonObservation: NSKeyValueObservation?
    
    // MARK: - Methods
    init(action: WebPageSelectionAction, state: WebPageSelectionState) {
        self.action = action
        self.state = state
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewWebView = .init(frame: .zero, configuration: .init())
        wrapView.fitAllAnchor(previewWebView)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        action.viewDidDisapper()
    }
    
    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        action.didTapSetWallpaperButton(value: urlSearchField.stringValue)
    }
}

extension WebPageSelectionViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            action.enteredSearchField(value: urlSearchField.stringValue)
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
