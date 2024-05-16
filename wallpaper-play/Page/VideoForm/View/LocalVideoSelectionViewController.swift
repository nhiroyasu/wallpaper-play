import Cocoa
import AVFoundation

class LocalVideoSelectionViewController: NSViewController {
    
    struct State: Statable {
        var videoFile: URL?
        
        static var initial: LocalVideoSelectionViewController.State {
            .init(videoFile: nil)
        }
    }
    
    @IBOutlet weak var thumbnailImageView: AntialiasedImageView!
    @IBOutlet weak var filePathLabel: NSTextField!
    @IBOutlet weak var videoWrappingView: NSView! {
        didSet {
            videoWrappingView.wantsLayer = true
            videoWrappingView.layer?.borderWidth = 1
            videoWrappingView.layer?.borderColor = NSColor.tertiaryLabelColor.cgColor
            videoWrappingView.layer?.cornerRadius = 8
        }
    }
    @IBOutlet weak var videoSizePopUpButton: NSPopUpButton! {
        didSet {
            videoSizePopUpButton.menu?.items = [
            ]
        }
    }
    @IBOutlet weak var muteToggleButton: NSButton!
    var videoView: VideoView!
    var action: LocalVideoSelectionAction!
    
    lazy var state: StateVariable<State> = .init { [weak self] state in
        self?.filePathLabel.stringValue = state.videoFile?.lastPathComponent ?? ""
    }
    
    init(action: LocalVideoSelectionAction) {
        self.action = action
        super.init(nibName: "LocalVideoSelectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideoSizePopUpButton()
        action.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // TODO: ここで動画再生
    }
    
    override func viewWillDisappear() {
        super.viewDidAppear()
        action.viewWillDisappear()
    }
    
    @IBAction func didTapVideoSelectionButton(_ sender: Any) {
        action?.didTapVideoSelectionButton()
    }
    
    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        guard let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem),
              let videoLink = state.get(\.videoFile) else { return }
        action?.didTapWallpaperButton(videoLink: videoLink.absoluteString, mute: isMute(), videoSize: videoSize)
    }
    
    private func setUpVideoSizePopUpButton() {
        videoSizePopUpButton.menu?.items = VideoSize.allCases.map {
            .init(title: $0.text, action: nil, keyEquivalent: "")
        }
        videoSizePopUpButton.selectItem(at: 0)
    }

    private func isMute() -> Bool {
        muteToggleButton.state == .on
    }
}
