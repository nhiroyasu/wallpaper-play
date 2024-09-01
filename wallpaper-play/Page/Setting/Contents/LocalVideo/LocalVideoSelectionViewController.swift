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
    @IBOutlet weak var muteToggleButton: NSButton!
    private var videoView: VideoView!
    private let presenter: LocalVideoSelectionPresenter
    private let avManager: AVPlayerManager
    private var selectedVideoUrl: URL?

    init(
        presenter: LocalVideoSelectionPresenter,
        avManager: AVPlayerManager
    ) {
        self.presenter = presenter
        self.avManager = avManager
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
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // TODO: ここで動画再生
    }
    
    override func viewWillDisappear() {
        super.viewDidAppear()
        avManager.clear()
        videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    @IBAction func didTapVideoSelectionButton(_ sender: Any) {
        presenter.didTapVideoSelectionButton()
    }
    
    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        guard let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem),
              let selectedVideoUrl else { return }
        presenter.didTapWallpaperButton(videoLink: selectedVideoUrl.absoluteString, mute: isMute(), videoSize: videoSize)
    }
    
    private func isMute() -> Bool {
        muteToggleButton.state == .on
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
