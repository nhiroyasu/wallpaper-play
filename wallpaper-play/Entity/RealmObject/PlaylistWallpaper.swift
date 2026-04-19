import Foundation
import RealmSwift

// NOTE: Added at realm schema version 11.
class PlaylistWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var playlistId: UUID
    @Persisted var targetMonitor: String? // if nil, same on all monitors.

    convenience init(
        date: Date,
        playlistId: UUID,
        targetMonitor: String?
    ) {
        self.init()
        self.date = date
        self.playlistId = playlistId
        self.targetMonitor = targetMonitor
    }
}
