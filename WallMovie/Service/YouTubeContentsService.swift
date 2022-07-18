import Foundation
import AppKit

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
}

class YouTubeContentsServiceImpl: YouTubeContentsService {
    func buildFullIframeUrl(id: String, mute: Bool) -> URL? {
        let muteValue = mute ? "1" : "0"
        let path = "https://www.youtube.com/embed/\(id)?playlist=\(id)&mute=\(muteValue)&loop=1&autoplay=1&controls=0&disablekb&fs=0&modestbranding=1&iv_load_policy=3&rel=0"
        return URL(string: path)
    }
    
    func buildThumbnailUrl(id: String, quality: YouTubeThumbnailQuality) -> URL? {
        let path = "https://img.youtube.com/vi/\(id)/\(quality.rawValue).jpg"
        return URL(string: path)
    }
}
