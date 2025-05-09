import Cocoa
import AVFoundation

protocol LocalVideoSelectionViewOutput: AnyObject {
    func setThumbnail(videoUrl: URL)
    func setPreview(videoUrl: URL)
    func setFilePath(videoUrl: URL)
}

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
            videoSizePopUpButton.menu?.items = VideoSize.allCases.map {
                .init(title: $0.text, action: nil, keyEquivalent: "")
            }
            videoSizePopUpButton.selectItem(at: 0)
        }
    }
    @IBOutlet weak var displayTargetPopUpButton: NSPopUpButton!
    @IBOutlet weak var backgroundColorPicker: NSColorWell! {
        didSet {
            backgroundColorPicker.color = .white
            if #available(macOS 14.0, *) {
                backgroundColorPicker.supportsAlpha = false
            }
        }
    }
    @IBOutlet weak var muteToggleButton: NSButton!
    private var videoView: VideoView!
    private let presenter: any LocalVideoSelectionPresenter
    private let avManager: any AVPlayerManager
    private var selectedVideoUrl: URL?
    private let displayTargetMenu: [DisplayTargetMenu]

    init(
        presenter: any LocalVideoSelectionPresenter,
        avManager: any AVPlayerManager
    ) {
        self.presenter = presenter
        self.avManager = avManager
        self.displayTargetMenu = [.allMonitors] + NSScreen.screens.map { .screen($0) }
        super.init(nibName: "LocalVideoSelectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoView = .init(frame: .zero)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoWrappingView.fitAllAnchor(videoView)
        if let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem) {
            updateColorPicker(from: videoSize)
        }

        setUpDisplayTargetPopUpButton()
    }

    override func viewWillDisappear() {
        super.viewDidAppear()
        avManager.clear()
        videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    @IBAction func didTapVideoSelectionButton(_ sender: Any) {
        presenter.didTapVideoSelectionButton()
    }

    @IBAction func didSelectVideoSize(_ sender: Any) {
        if let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem) {
            updateColorPicker(from: videoSize)
        }
    }

    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        guard let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem),
              let selectedVideoUrl else { return }
        let backgroundColor: NSColor? = switch videoSize {
        case .aspectFill:
            nil
        case .aspectFit:
            backgroundColorPicker.color
        }

        let displayTargetMenu = displayTargetMenu[displayTargetPopUpButton.indexOfSelectedItem]

        presenter.didTapWallpaperButton(
            videoLink: selectedVideoUrl.absoluteString,
            mute: isMute(),
            videoSize: videoSize,
            backgroundColor: backgroundColor,
            displayTargetMenu: displayTargetMenu
        )
    }
    
    private func isMute() -> Bool {
        muteToggleButton.state == .on
    }

    private func updateColorPicker(from videoSize: VideoSize) {
        switch videoSize {
        case .aspectFill:
            backgroundColorPicker.isHidden = true
        case .aspectFit:
            backgroundColorPicker.isHidden = false
        }
    }

    private func setUpDisplayTargetPopUpButton() {
        displayTargetPopUpButton.menu?.items = displayTargetMenu.map { menu in
            NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
        }
    }
}

extension LocalVideoSelectionViewController: LocalVideoSelectionViewOutput {
    func setThumbnail(videoUrl: URL) {
        let generator = AVAssetImageGenerator(asset: AVAsset(url: videoUrl))
        do {
            let image = try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), actualTime: nil)
            thumbnailImageView.image = image.toNSImage
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }

    func setPreview(videoUrl: URL) {
        let player = avManager.set([videoUrl])
        setUpVideoView(player: player)
        do {
            try avManager.mute(true)
            try avManager.loop(type: .oneLoop)
            try avManager.start()
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }

    private func setUpVideoView(player: AVPlayer) {
        videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        videoView.setPlayerLayer(layer)
    }

    func setFilePath(videoUrl: URL) {
        selectedVideoUrl = videoUrl
        filePathLabel.stringValue = videoUrl.lastPathComponent
    }
}
