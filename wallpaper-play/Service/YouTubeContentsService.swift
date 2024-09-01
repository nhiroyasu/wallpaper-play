import Foundation
import AppKit
import Injectable

enum YouTubeThumbnailQuality: String {
    case `default`
    /// max
    case maxresdefault
    /// high
    case hqdefault
    /// middle
    case mqdefault
    /// sd
    case sddefault
}

protocol YouTubeContentsService {
    func buildFullIframeUrl(id: String, mute: Bool) -> URL?
    func buildThumbnailUrl(id: String, quality: YouTubeThumbnailQuality) -> URL?
    func buildYouTubeLink(id: String) -> URL?
    func replaceMutedIframeUrl(url: URL) -> URL?
    func getInfo(embedLink: String) -> (videoId: String, isMute: Bool)?
    func getVideoId(youtubeLink: String) -> String?
    func isYouTubeDomain(link: String) -> Bool
}

class YouTubeContentsServiceImpl: YouTubeContentsService {
    private let urlResolverService: any URLResolverService

    init(injector: any Injectable = Injector.shared) {
        self.urlResolverService = injector.build()
    }

    func buildFullIframeUrl(id: String, mute: Bool) -> URL? {
        let muteValue = mute ? "1" : "0"
        let path = "https://www.youtube.com/embed/\(id)?playlist=\(id)&mute=\(muteValue)&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0"
        return URL(string: path)
    }
    
    func buildThumbnailUrl(id: String, quality: YouTubeThumbnailQuality) -> URL? {
        let path = "https://img.youtube.com/vi/\(id)/\(quality.rawValue).jpg"
        return URL(string: path)
    }

    func buildYouTubeLink(id: String) -> URL? {
        let path = "https://www.youtube.com/watch?v=\(id)"
        return URL(string: path)
    }

    func replaceMutedIframeUrl(url: URL) -> URL? {
        let mutedUrlStr = url.absoluteString.replacingOccurrences(of: "mute=0", with: "mute=1")
        return URL(string: mutedUrlStr)
    }

    func getInfo(embedLink: String) -> (videoId: String, isMute: Bool)? {
        guard isYouTubeDomain(link: embedLink) else { return nil }

        if let url = URL(string: embedLink),
           let urlContent = urlResolverService.resolve(url) {
            let videoId = url.lastPathComponent
            let isMute = urlContent.queryItems.first(where: { $0.name == "mute" })?.value == "1"
            return (videoId, isMute)
        } else {
            return nil
        }
    }

    func getVideoId(youtubeLink: String) -> String? {
        guard isYouTubeDomain(link: youtubeLink) else { return nil }

        if let urlContent = urlResolverService.resolve(youtubeLink),
           let videoId = urlContent.queryItems.first(where: { $0.name == "v" })?.value {
            return videoId
        } else {
            return nil
        }
    }

    func isYouTubeDomain(link: String) -> Bool {
        return URL(string: link)?.host?.contains("youtube.com") ?? true
    }
}
