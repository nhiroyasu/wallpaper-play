import Foundation
import RealmSwift

class LocalVideoWallpaper: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var urls: List<URL>
    @Persisted var config: LocalVideoConfig?
    
    convenience init(
        date: Date,
        urls: [URL],
        config: LocalVideoConfig
    ) {
        self.init()
        let tmpUrls = List<URL>()
        urls.forEach { url in
            tmpUrls.append(url)
        }
        self.date = date
        self.urls = tmpUrls
        self.config = config
    }
}
