import Injectable
import RealmSwift

protocol RealmMigrationService {
    func migrateForV3(migration: Migration, oldSchemaVersion: UInt64)
    func migrateForV4(migration: Migration, oldSchemaVersion: UInt64)
}

class RealmMigrationServiceImpl: RealmMigrationService {
    private let youtubeContentService: any YouTubeContentsService

    init(injector: any Injectable) {
        youtubeContentService = injector.build()
    }

    func migrateForV3(migration: Migration, oldSchemaVersion: UInt64) {
        if oldSchemaVersion < 3 {
            migration.enumerateObjects(ofType: LocalVideoWallpaper.className()) { oldObject, newObject in
                let urls = oldObject?["urls"] as? List<String>
                if let urlStr = urls?.first{
                    newObject?["url"] = urlStr
                } else {
                    if let oldObject = oldObject {
                        migration.delete(oldObject)
                    }
                }
            }
        }
    }

    func migrateForV4(migration: Migration, oldSchemaVersion: UInt64) {
        if oldSchemaVersion < 4 {
            migration.enumerateObjects(ofType: YouTubeWallpaper.className()) { [weak self] oldObject, newObject in
                guard let self else { return }
                guard let urlStr = oldObject?["url"] as? String else { return }

                if let youtubeInfo = youtubeContentService.getInfo(embedLink: urlStr) {
                    newObject?["videoId"] = youtubeInfo.videoId
                    newObject?["isMute"] = youtubeInfo.isMute
                } else {
                    if let oldObject = oldObject {
                        migration.delete(oldObject)
                    }
                }
            }
        }
    }
}
