import Foundation
import RealmSwift
import Injectable

fileprivate let SCHEMA_VERSION: UInt64 = 3

public enum RealmConfigType {
    case release
    case debug1
    case inMemory
}

public protocol RealmService {
    func buildRealm() -> Realm
    func buildConfig(type: RealmConfigType) throws -> Realm.Configuration
    // MARK: - for debug
    func compactRealm()
    func getRealmURL() -> URL?
}

public class RealmManagerImpl: RealmService {
    
    private let applicationFileManager: ApplicationFileManager
    private let fileManager: FileManager
    
    public init(injector: Injectable) {
        applicationFileManager = injector.build()
        fileManager = .default
    }
    
    public func buildRealm() -> Realm {
        do {
            #if DEBUG
            let config = buildConfig(type: .debug1)
            return try Realm(configuration: config)
            #else
            let config = buildConfig(type: .release)
            return try Realm(configuration: config)
            #endif
        } catch(let e) {
            fatalError(e.localizedDescription)
        }
    }
    
    public func compactRealm() {
        #if DEBUG
        let realm = buildRealm()
        let defaultURL = realm.configuration.fileURL!
        let defaultParentURL = defaultURL.deletingLastPathComponent()
        let compactedURL = defaultParentURL.appendingPathComponent("default-compact.realm")

        autoreleasepool {
            try! realm.writeCopy(toFile: compactedURL)
            try! fileManager.removeItem(at: defaultURL)
            try! fileManager.moveItem(at: compactedURL, to: defaultURL)
        }
        #endif
    }
    
    public func buildConfig(type: RealmConfigType) -> Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = SCHEMA_VERSION
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < SCHEMA_VERSION {
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

        switch type {
        case .release:
            if let url = applicationFileManager.getDirectory(.realm) {
                config.fileURL = url.appendingPathComponent("db.realm")
            }
        case .debug1:
            if let url = applicationFileManager.getDirectory(.debugRealm) {
                config.fileURL = url.appendingPathComponent("db.realm")
            }
        case .inMemory:
            config = Realm.Configuration(inMemoryIdentifier: String(describing: Self.self))
        }
        return config
    }

    public func getRealmURL() -> URL? {
        let config = buildConfig(type: .debug1)
        return config.fileURL
    }
}
