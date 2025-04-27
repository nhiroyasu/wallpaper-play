import Foundation
import RealmSwift

class LocalVideoWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var url: URL
    @Persisted var config: LocalVideoConfig?
    // NOTE: Added at realm schema version 9.
    @Persisted var targetMonitor: String? // if nil, same on all monitors.

    convenience init(
        date: Date,
        url: URL,
        config: LocalVideoConfig,
        targetMonitor: String?
    ) {
        self.init()
        self.date = date
        self.url = url
        self.config = config
        self.targetMonitor = targetMonitor
    }
}
