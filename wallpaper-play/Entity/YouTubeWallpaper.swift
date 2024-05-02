import Foundation
import RealmSwift

class YouTubeWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var videoId: String
    @Persisted var isMute: Bool

    convenience init(
        date: Date,
        videoId: String,
        isMute: Bool
    ) {
        self.init()
        self.date = date
        self.videoId = videoId
        self.isMute = isMute
    }
}
