import Foundation
import RealmSwift

class YouTubeWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var videoId: String
    @Persisted var isMute: Bool
    @Persisted var size: Int
    // NOTE: Added at realm schema version 9.
    @Persisted var targetMonitor: String? // if nil, same on all monitors.

    convenience init(
        date: Date,
        videoId: String,
        isMute: Bool,
        size: Int,
        targetMonitor: String?
    ) {
        self.init()
        self.date = date
        self.videoId = videoId
        self.isMute = isMute
        self.size = size
        self.targetMonitor = targetMonitor
    }
}
