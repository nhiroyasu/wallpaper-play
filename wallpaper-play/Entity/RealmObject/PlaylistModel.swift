import Foundation
import RealmSwift

// NOTE: Added at realm schema version 10
class PlaylistModel: Object, DateSortable {
    @Persisted var date: Date
    @Persisted var uuid: UUID
    @Persisted var name: String
    @Persisted var playbackMode: Int
    @Persisted var videoSize: Int
    @Persisted var backgroundColor: ColorHex
    @Persisted var isMute: Bool
    @Persisted var targetMonitor: String?
    @Persisted var items: List<PlaylistItemModel>

    convenience init(
        date: Date,
        id: UUID,
        name: String,
        playbackMode: Int,
        videoSize: Int,
        backgroundColor: ColorHex,
        isMute: Bool,
        targetMonitor: String?,
        items: [PlaylistItemModel]
    ) {
        self.init()
        self.date = date
        self.uuid = id
        self.name = name
        self.playbackMode = playbackMode
        self.videoSize = videoSize
        self.backgroundColor = backgroundColor
        self.isMute = isMute
        self.targetMonitor = targetMonitor
        self.items.append(objectsIn: items)
    }
}

// NOTE: Added at realm schema version 10
class PlaylistItemModel: EmbeddedObject {
    @Persisted var url: URL

    convenience init(url: URL) {
        self.init()
        self.url = url
    }
}
