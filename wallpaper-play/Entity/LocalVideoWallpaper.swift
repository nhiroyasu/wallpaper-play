import Foundation
import RealmSwift

class LocalVideoWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var url: URL
    @Persisted var config: LocalVideoConfig?
    
    convenience init(
        date: Date,
        url: URL,
        config: LocalVideoConfig
    ) {
        self.init()
        self.date = date
        self.url = url
        self.config = config
    }
}
