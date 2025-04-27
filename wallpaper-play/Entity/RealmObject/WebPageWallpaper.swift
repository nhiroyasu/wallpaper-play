import Foundation
import RealmSwift

class WebPageWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var url: URL
    // NOTE: Added at realm schema version 5.
    @Persisted var arrowOperation: Bool?
    // NOTE: Added at realm schema version 9.
    @Persisted var targetMonitor: String? // if nil, same on all monitors.

    convenience init(
        date: Date,
        url: URL,
        arrowOperation: Bool?,
        targetMonitor: String?
    ) {
        self.init()
        self.date = date
        self.url = url
        self.arrowOperation = arrowOperation
        self.targetMonitor = targetMonitor
    }
}
