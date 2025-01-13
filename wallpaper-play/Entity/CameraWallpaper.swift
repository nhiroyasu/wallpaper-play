import Foundation
import RealmSwift

// NOTE: Added at realm schema version 7.
class CameraWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var deviceId: String
    @Persisted var size: Int

    convenience init(
        date: Date,
        deviceId: String,
        size: Int
    ) {
        self.init()
        self.date = date
        self.deviceId = deviceId
        self.size = size
    }
}
