import Cocoa
import AVFoundation
import Combine

protocol CameraSelectionViewOutput: AnyObject {
    func setCamerasPopUpButton(titles: [String])
    func selectCamera(selectedCamera: String)
}


class CameraSelectionViewController: NSViewController {
    @IBOutlet weak var camerasPopUpButton: NSPopUpButton!
    @IBOutlet weak var cameraDisplayView: NonInteractionView!
    @IBOutlet weak var previewAnnotationLabel: NSTextField!
    @IBOutlet weak var videoSizePopUpButton: NSPopUpButton! {
        didSet {
            videoSizePopUpButton.menu?.items = VideoSize.allCases.map {
                .init(title: $0.text, action: nil, keyEquivalent: "")
            }
            videoSizePopUpButton.selectItem(at: 0)
        }
    }
    @IBOutlet weak var displayTargetPopUpButton: NSPopUpButton!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    let presenter: any CameraSelectionPresenter
    let notificationManager: any NotificationManager
    let cameraDeviceService: any CameraDeviceService
    let appState: AppState
    private let displayTargetMenu: [DisplayTargetMenu]
    private var captureSession: AVCaptureSession!
    private var cameraDevices: [AVCaptureDevice] = []
    private var cancellable: Set<AnyCancellable> = []

    private let captureSessionQueue = DispatchQueue(label: "com.nhiro1109.wallpaper-play.captureSessionQueue")

    init(
        presenter: any CameraSelectionPresenter,
        notificationManager: any NotificationManager,
        cameraDeviceService: any CameraDeviceService,
        appState: AppState
    ) {
        self.presenter = presenter
        self.notificationManager = notificationManager
        self.cameraDeviceService = cameraDeviceService
        self.appState = appState
        self.displayTargetMenu = [.allMonitors] + NSScreen.screens.map { .screen($0) }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        captureSession.stopRunning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpDisplayTargetPopUpButton()
        cameraDevices = cameraDeviceService.fetchDevices()

        setUpPopUpButton()
        setUpCameraPreview()
        setPreviewAnnotationLabel()
        observeWallpaperRequest()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if isSettingCameraAsWallpaper() {
            captureSessionQueue.async { [weak self] in
                self?.captureSession.stopRunning()
            }
            previewAnnotationLabel.isHidden = false
        } else {
            captureSessionQueue.async { [weak self] in
                self?.captureSession.startRunning()
            }
            previewAnnotationLabel.isHidden = true
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        captureSessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
        previewAnnotationLabel.isHidden = false
    }

    @IBAction func didSelectCamera(_ sender: Any) {
        if let selectedCamera = cameraDevices.first(where: { $0.localizedName == camerasPopUpButton.titleOfSelectedItem }) {
            changeCameraPreview(device: selectedCamera)
        }
    }
    
    @IBAction func didTapSetWallpaperButton(_ sender: Any) {
        if let selectedCamera = cameraDevices.first(where: { $0.localizedName == camerasPopUpButton.titleOfSelectedItem }),
           let videoSize = VideoSize(rawValue: videoSizePopUpButton.indexOfSelectedItem) {
            let displayTargetMenu = displayTargetMenu[displayTargetPopUpButton.indexOfSelectedItem]
            presenter.didTapSetWallpaperButton(selectedCamera: selectedCamera, videoSize: videoSize, displayTargetMenu: displayTargetMenu)
        }
    }

    // MARK: - Internal

    func setUpPopUpButton() {
        let titles = cameraDevices.map { $0.localizedName }
        camerasPopUpButton.removeAllItems()
        camerasPopUpButton.addItems(withTitles: titles)
    }

    func setUpCameraPreview() {
        guard let camera = cameraDevices.first else { return }
        captureSession = AVCaptureSession()

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSessionQueue.async { [weak self] in
                    self?.captureSession.addInput(input)
                }
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraDisplayView.bounds
            previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

            cameraDisplayView.layer = CALayer()
            cameraDisplayView.layer?.addSublayer(previewLayer)

            if isSettingCameraAsWallpaper() {
                // do nothing
            } else {
                captureSessionQueue.async { [weak self] in
                    self?.captureSession.startRunning()
                }
            }
        } catch {
            print(error)
        }
    }

    func setPreviewAnnotationLabel() {
        if isSettingCameraAsWallpaper() {
            previewAnnotationLabel.isHidden = false
        } else {
            previewAnnotationLabel.isHidden = true
        }
    }

    private func setUpDisplayTargetPopUpButton() {
        displayTargetPopUpButton.menu?.items = displayTargetMenu.map { menu in
            NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
        }
    }

    func changeCameraPreview(device: AVCaptureDevice) {
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print(error)
        }
    }

    func observeWallpaperRequest() {
        // NOTE: When setting the camera as the wallpaper, the video stops when displaying the preview at the same time, so stop the preview when setting the camera as the wallpaper

        notificationManager
            .publisher(for: .requestCamera)
            .sink { [weak self] _ in
                self?.captureSessionQueue.async { [weak self] in
                    self?.captureSession.stopRunning()
                }
                self?.previewAnnotationLabel.isHidden = false
            }
            .store(in: &cancellable)

        notificationManager
            .publisher(for: .requestVideo)
            .sink { [weak self] _ in
                self?.previewAnnotationLabel.isHidden = true
            }
            .store(in: &cancellable)

        notificationManager
            .publisher(for: .requestYouTube)
            .sink { [weak self] _ in
                self?.previewAnnotationLabel.isHidden = true
            }
            .store(in: &cancellable)

        notificationManager
            .publisher(for: .requestWebPage)
            .sink { [weak self] _ in
                self?.previewAnnotationLabel.isHidden = true
            }
            .store(in: &cancellable)
    }

    private func isSettingCameraAsWallpaper() -> Bool {
        appState.wallpapers.contains(where: {
            if case .camera = $0.kind { true } else { false }
        })
    }
}

extension CameraSelectionViewController: CameraSelectionViewOutput {
    func setCamerasPopUpButton(titles: [String]) {
        camerasPopUpButton.removeAllItems()
        camerasPopUpButton.addItems(withTitles: titles)
    }

    func selectCamera(selectedCamera: String) {
        camerasPopUpButton.selectItem(withTitle: selectedCamera)
    }
}
