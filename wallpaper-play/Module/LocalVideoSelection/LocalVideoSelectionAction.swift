import Foundation
import Injectable

protocol LocalVideoSelectionAction {
    func viewDidLoad()
    func viewWillDisappear()
    func didTapVideoSelectionButton()
    func didTapWallpaperButton(videoLink: String, mute: Bool, videoSize: VideoSize)
}

class LocalVideoSelectionActionImpl: LocalVideoSelectionAction {
    
    private let fileSelectionService: FileSelectionManager
    private let useCase: LocalVideoSelectionUseCase
    
    public init(injector: Injectable = Injector.shared) {
        self.fileSelectionService = injector.build()
        self.useCase = injector.build(LocalVideoSelectionUseCase.self)
    }
    
    func viewDidLoad() {
        useCase.setUp()
    }
    
    func viewWillDisappear() {
        useCase.clearPreview()
    }
    
    func didTapVideoSelectionButton() {
        guard let url = fileSelectionService.open(fileType: .movie) else { return }
        useCase.confirmVideo(url: url)
    }
    
    func didTapWallpaperButton(videoLink: String, mute: Bool, videoSize: VideoSize) {
        guard let url = URL(string: videoLink) else { return }
        let input = VideoConfigInput(link: url, mute: mute, videoSize: videoSize)
        useCase.requestSettingWallpaper(input)
    }
}
