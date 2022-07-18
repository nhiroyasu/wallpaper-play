import Cocoa

class WebPageSelectionViewController: NSViewController {

    // MARK: - Views
    @IBOutlet weak var urlSearchField: NSSearchField! {
        didSet {
            urlSearchField.delegate = self
        }
    }
    @IBOutlet weak var confirmButton: NSButton!
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
        observeState()
        observeParams()
    }
    
    private func observeState() {
        inputObservation = state.observe(\.input, options: [.new], changeHandler: { state, changeValue in
            return
        })
        
        previewUrlObservation = state.observe(\.previewUrl, options: [.new], changeHandler: { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            if let url = value {
                self?.previewWebView.load(URLRequest(url: url))
            } else {
                self?.previewWebView.loadHTMLString("", baseURL: nil)
            }
        })
        
        isEnableSetWallpaperButtonObservation = state.observe(\.isEnableSetWallpaperButton, options: [.initial, .new], changeHandler: { [weak self] state, changeValue in
            guard let value = changeValue.newValue else { return }
            self?.setWallpaperButton.isEnabled = value
        })
    }
    
    private func observeParams() {
        NotificationCenter.default.addObserver(forName: NSTextField.textDidChangeNotification, object: nil, queue: nil) { [weak self] notification in
            guard let target = notification.userInfo?["NSFieldEditor"] as? NSTextView else { return }
            self?.state.input = target.string
        }
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        action.didTapConfirmButton()
    }
    
    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        action.didTapSetWallpaperButton()
    }
}

extension WebPageSelectionViewController: NSSearchFieldDelegate {
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            action.enteredSearchField()
            return false
        } else if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            return false
        }
        return false
    }
}
