import Foundation
import RealmSwift
import Injectable

let REALM_SCHEMA_VERSION: UInt64 = 6

public enum RealmConfigType {
    case release
    case debug1
    case inMemory
}

public protocol RealmService {
    func buildRealm() -> Realm
    // MARK: - for debug
    func compactRealm()
    func getRealmURL() -> URL?
}

public class RealmManagerImpl: RealmService {
    
    private let applicationFileManager: any ApplicationFileManager
    private let migrationService: any RealmMigrationService
    private let fileManager: FileManager
    
    public init(injector: any Injectable) {
        applicationFileManager = injector.build()
        migrationService = injector.build()
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
    
    func buildConfig(type: RealmConfigType) -> Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = REALM_SCHEMA_VERSION
        config.migrationBlock = { [weak self] migration, oldSchemaVersion in
            guard let self else { return }
            migrationService.migrateForV3(migration: migration, oldSchemaVersion: oldSchemaVersion)
            migrationService.migrateForV4(migration: migration, oldSchemaVersion: oldSchemaVersion)
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
