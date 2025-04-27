import Foundation
import RealmSwift

// NOTE: Added at realm schema version 7.
class CameraWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var deviceId: String
    @Persisted var size: Int
    // NOTE: Added at realm schema version 9.
    @Persisted var targetMonitor: String? // if nil, same on all monitors.

    convenience init(
        date: Date,
        deviceId: String,
        size: Int,
        targetMonitor: String?
    ) {
        self.init()
        self.date = date
        self.deviceId = deviceId
        self.size = size
        self.targetMonitor = targetMonitor
    }
}
