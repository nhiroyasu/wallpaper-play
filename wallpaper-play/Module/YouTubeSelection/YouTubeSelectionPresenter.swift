import Foundation
import Injectable

protocol YouTubeSelectionPresenter {
    func updatePreview(youtubeLink: URL)
    func updateThumbnail(url: URL)
    func setEnableWallpaperButton(_ value: Bool)
    func showValidateAlert()
    func showCommonAlert()
}

class YouTubeSelectionPresenterImpl: YouTubeSelectionPresenter {
    private let alertService: AlertManager
    var output: YouTubeSelectionViewController!
    
    init(injector: Injectable) {
        self.alertService = injector.build()
    }
    
    func updatePreview(youtubeLink: URL) {
        output.youtubeWebView.load(URLRequest(url: youtubeLink))
    }
    
    func updateThumbnail(url: URL) {
        output.thumbnailImageView.setImage(url: url)
        
        if let target = ApplicationFileManagerImpl().getDirectory(.latestThumb)?.appendingPathComponent("latest.png"), let _ = try? Data(contentsOf: url).write(to: target) {} else {
            // For now, only log. Will switch to guard if it has any serious consequences
            NSLog("Could not save thumbnail! Proceeding without wallpaper...")
        }
    }
    
    func setEnableWallpaperButton(_ value: Bool) {
        output.wallpaperButton.isEnabled = value
    }
    
    func showValidateAlert() {
        alertService.warning(msg: LocalizedString(key: .error_invalid_youtube_url), completionHandler: {})
    }
    
    func showCommonAlert() {
        alertService.warning(msg: LocalizedString(key: .error_common), completionHandler: {})
    }
}
