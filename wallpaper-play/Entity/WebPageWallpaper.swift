import Foundation
import RealmSwift

class WebPageWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var url: URL
    
    convenience init(
        date: Date,
        url: URL
    ) {
        self.init()
        self.date = date
        self.url = url
    }
}
