import Foundation
import Injectable

protocol YouTubeSelectionUseCase {
    func initialSetUp()
    func confirmIfValidYouTubeLink(_ youtubeLink: String)
    func confirm(_ youtubeLink: String)
    func requestSettingWallpaper(youtubeLink: String, mute: Bool)
}

class YouTubeSelectionInteractor: YouTubeSelectionUseCase {
    private let presenter: YouTubeSelectionPresenter
    private let urlResolverService: URLResolverService
    private let youtubeContentService: YouTubeContentsService
    private let notificationManager: NotificationManager

    internal init(injector: Injectable = Injector.shared) {
        self.presenter = injector.build(YouTubeSelectionPresenter.self)
        self.urlResolverService = injector.build()
        self.youtubeContentService = injector.build()
        self.notificationManager = injector.build()
    }

    func initialSetUp() {
        if let path = Bundle.main.path(forResource: "youtube_description", ofType: "png") {
            presenter.updatePreview(youtubeLink: URL(fileURLWithPath: path))
        }
    }

    func confirmIfValidYouTubeLink(_ youtubeLink: String) {
        guard validateYouTubeLink(youtubeLink),
              let urlContent = urlResolverService.resolve(youtubeLink),
              urlContent.queryItems.first(where: { $0.name == "v" })?.value != nil else {
            return
        }
        confirm(youtubeLink)
    }

    func confirm(_ youtubeLink: String) {
        guard validateYouTubeLink(youtubeLink) else {
            presenter.showValidateAlert()
            return
        }
        
        let urlContent = urlResolverService.resolve(youtubeLink)
        if let youtubeId = urlContent?.queryItems.first(where: { $0.name == "v" })?.value,
           let youtubeUrl = youtubeContentService.buildFullIframeUrl(id: youtubeId, mute: true),
           let thumbnailUrl = youtubeContentService.buildThumbnailUrl(id: youtubeId, quality: .mqdefault) {
            presenter.updatePreview(youtubeLink: youtubeUrl)
            presenter.updateThumbnail(url: thumbnailUrl)
            presenter.setEnableWallpaperButton(true)
        } else {
            presenter.showCommonAlert()
        }
    }
    
    func requestSettingWallpaper(youtubeLink: String, mute: Bool) {
        guard validateYouTubeLink(youtubeLink) else {
            presenter.showValidateAlert()
            return
        }
        
        let urlContent = urlResolverService.resolve(youtubeLink)
        guard let youtubeId = urlContent?.queryItems.first(where: { $0.name == "v" })?.value else {
            presenter.showValidateAlert()
            return
        }
        
        notificationManager.push(
            name: .requestYouTube,
            param: NotificationRequestVideoTDO(videoId: youtubeId, isMute: mute)
        )
    }
    
    private func validateYouTubeLink(_ link: String) -> Bool {
        let urlRegEx = "^https?://(www\\.)?youtube\\.com[\\w!?/+\\-_~=;.,*&@#$%\\.\\-/:]*$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: link)
        return result
    }
}
