import Foundation
import Injectable

struct VideoConfigInput {
    let link: URL
    let mute: Bool
    let videoSize: VideoSize
}

typealias VideoConfigOutput = VideoConfigInput

protocol LocalVideoSelectionUseCase {
    func setUp()
    func confirmVideo(url: URL)
    func clearPreview()
    func requestSettingWallpaper(_ input: VideoConfigInput)
}

class LocalVideoSelectionInteractor: LocalVideoSelectionUseCase {
    
    private let notificationManager: NotificationManager
    private let presenter: LocalVideoSelectionPresenter
    
    internal init(injector: Injectable = Injector.shared) {
        self.notificationManager = injector.build()
        self.presenter = injector.build(LocalVideoSelectionPresenter.self)
    }
    
    func setUp() {
        presenter.initViews()
    }
    
    func confirmVideo(url: URL) {
        presenter.setThumbnail(videoUrl: url)
        presenter.setPreview(videoUrl: url)
        presenter.setFilePath(videoUrl: url)
    }
    
    func clearPreview() {
        presenter.removePreview()
    }
    
    func requestSettingWallpaper(_ input: VideoConfigInput) {
        notificationManager.push(name: .requestVideo, param: VideoPlayValue(urls: [input.link], mute: input.mute, videoSize: input.videoSize))
    }
}
