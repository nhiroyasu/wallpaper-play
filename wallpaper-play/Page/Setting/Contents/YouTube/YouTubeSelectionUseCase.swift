import Foundation
import Injectable

protocol YouTubeSelectionUseCase {
    func retrieveIFrameUrl(from youtubeLink: String) -> URL?
    func retrieveThumbnailUrl(from youtubeLink: String) -> URL?
    func retrieveVideoId(from youtubeLink: String) -> String?
    func requestWallpaper(videoId: String, mute: Bool)
}

class YouTubeSelectionInteractor: YouTubeSelectionUseCase {
    private let urlResolverService: any URLResolverService
    private let youtubeContentService: any YouTubeContentsService
    private let wallpaperRequestService: any WallpaperRequestService

    init(
        urlResolverService: any URLResolverService,
        youtubeContentService: any YouTubeContentsService,
        wallpaperRequestService: any WallpaperRequestService
    ) {
        self.urlResolverService = urlResolverService
        self.youtubeContentService = youtubeContentService
        self.wallpaperRequestService = wallpaperRequestService
    }

    func retrieveIFrameUrl(from youtubeLink: String) -> URL? {
        guard validateYouTubeLink(youtubeLink) else { return nil }
        let urlContent = urlResolverService.resolve(youtubeLink)
        guard let youtubeId = urlContent?.queryItems.first(where: { $0.name == "v" })?.value,
              let iframeUrl = youtubeContentService.buildFullIframeUrl(id: youtubeId, mute: true) else { return nil }
        return iframeUrl
    }

    func retrieveThumbnailUrl(from youtubeLink: String) -> URL? {
        guard validateYouTubeLink(youtubeLink) else { return nil }
        let urlContent = urlResolverService.resolve(youtubeLink)
        if let youtubeId = urlContent?.queryItems.first(where: { $0.name == "v" })?.value,
           let thumbnailUrl = youtubeContentService.buildThumbnailUrl(id: youtubeId, quality: .mqdefault) {
            return thumbnailUrl
        } else {
            return nil
        }
    }

    func retrieveVideoId(from youtubeLink: String) -> String? {
        guard validateYouTubeLink(youtubeLink) else { return nil }
        let urlContent = urlResolverService.resolve(youtubeLink)
        return urlContent?.queryItems.first(where: { $0.name == "v" })?.value
    }

    func requestWallpaper(videoId: String, mute: Bool) {
        wallpaperRequestService.requestYoutubeWallpaper(youtube: YouTubePlayValue(videoId: videoId, isMute: mute))
    }

    // MARK: - internal

    private func validateYouTubeLink(_ link: String) -> Bool {
        let urlRegEx = "^https?://(www\\.)?youtube\\.com[\\w!?/+\\-_~=;.,*&@#$%\\.\\-/:]*$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: link)
        return result
    }
}
