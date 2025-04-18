import Cocoa
import AVFoundation
import WebKit

protocol WallpaperViewOutput {
    func display(_ displayType: WallpaperDisplayType)
}

class WallpaperViewController: NSViewController {

    var webView: WallpaperWebView!
    var youtubeView: WallpaperWebView!
    var videoView: VideoView!
    var cameraView: NSView!
    private let wallpaperSize: NSSize
    private let avManager: any AVPlayerManager
    private var captureSession: AVCaptureSession?
    private let presenter: any WallpaperPresenter

    init(
        wallpaperSize: NSSize,
        presenter: any WallpaperPresenter,
        avManager: any AVPlayerManager
    ) {
        self.wallpaperSize = wallpaperSize
        self.presenter = presenter
        self.avManager = avManager
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("not call")
    }

    deinit {
        captureSession?.stopRunning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoView = .init(frame: .init(origin: .zero, size: wallpaperSize))
        youtubeView = .init(frame: .zero, configuration: .youtubeWallpaper(videoSize: .aspectFit))
        webView = .init(frame: .zero, configuration: .webWallpaper)
        cameraView = .init(frame: .zero)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.fitAllAnchor(youtubeView)
        view.fitAllAnchor(webView)
        view.fitAllAnchor(videoView)
        view.fitAllAnchor(cameraView)

        presenter.viewDidLoad()
    }
}

extension WallpaperViewController: WallpaperViewOutput {
    func display(_ displayType: WallpaperDisplayType) {
        switch displayType {
        case .video(let url, let videoSize, let mute, let backgroundColor):
            allClear()
            videoView.isHidden = false
            let player = avManager.set([url])
            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = videoSize.videoGravity
            videoView.setPlayerLayer(layer)
            videoView.setBackgroundColor(backgroundColor)
            do {
                try avManager.mute(mute)
                try avManager.loop(type: .listLoop)
                try avManager.start()
            } catch {
                fatalError(error.localizedDescription)
            }
        case .youtube(let url, let videoSize):
            allClear()
            resetYoutubeView(videoSize: videoSize)
            youtubeView.isHidden = false
            youtubeView.load(URLRequest(url: url))
        case .web(let url, let arrowOperation):
            allClear()
            webView.isHidden = false
            webView.load(URLRequest(url: url))
            webView.setArrowOperation(arrowOperation)
        case .camera(let camera, let videoSize):
            allClear()
            cameraView.isHidden = false

            if captureSession == nil {
                captureSession = AVCaptureSession()
                captureSession!.sessionPreset = .high

                let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                cameraLayer.videoGravity = .from(videoSize)
                cameraLayer.frame = cameraView.bounds
                cameraLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                cameraView.layer = CALayer()
                cameraView.layer?.addSublayer(cameraLayer)
            }

            do {
                captureSession?.inputs.forEach { captureSession?.removeInput($0) }

                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession?.canAddInput(input) == true {
                    captureSession?.addInput(input)
                }

                captureSession?.startRunning()
            } catch {
                #if DEBUG
                fatalError(error.localizedDescription)
                #else
                NSLog(error.localizedDescription, [])
                #endif
            }

        case .none:
            allClear()
        }
    }
}

// MARK: - internal

extension WallpaperViewController {
    private func allClear() {
        removeVideo()
        removeYoutubeView()
        removeWebView()
        removeCameraView()
    }

    private func removeVideo() {
        videoView.isHidden = true
        videoView.layer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        avManager.clear()
    }

    private func resetYoutubeView(videoSize: VideoSize) {
        youtubeView.removeFromSuperview()
        youtubeView = .init(frame: .zero, configuration: .youtubeWallpaper(videoSize: videoSize))
        view.fitAllAnchor(youtubeView)
    }
    
    private func removeYoutubeView() {
        youtubeView.loadHTMLString("", baseURL: nil)
        youtubeView.setArrowOperation(false)
        youtubeView.isHidden = true
    }

    private func removeWebView() {
        webView.loadHTMLString("", baseURL: nil)
        webView.setArrowOperation(false)
        webView.isHidden = true
    }

    private func removeCameraView() {
        cameraView.isHidden = true
        captureSession?.stopRunning()
    }
}

enum WallpaperDisplayType {
    case video(URL, videoSize: VideoSize, mute: Bool, backgroundColor: NSColor?)
    case youtube(URL, videoSize: VideoSize)
    case web(URL, arrowOperation: Bool)
    case camera(captureDevice: AVCaptureDevice, videoSize: VideoSize)
    case none
}
