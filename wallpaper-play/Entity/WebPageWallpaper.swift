import Foundation
import RealmSwift

class WebPageWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var url: URL
    // NOTE: Added at realm schema version 5.
    @Persisted var arrowOperation: Bool?

    convenience init(
        date: Date,
        url: URL,
        arrowOperation: Bool?
    ) {
        self.init()
        self.date = date
        self.url = url
        self.arrowOperation = arrowOperation
    }
}
