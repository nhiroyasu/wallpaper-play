import XCTest
import RealmSwift
@testable import Wallpaper_Play

class RealmMigrationServiceTests: XCTestCase {
    var subject: RealmMigrationServiceImpl!

    override func setUpWithError() throws {
        subject = .init(injector: testInjector)
    }

    private func realmUrl(for schemaVersion: Int) -> URL {
        let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
        let defaultParentURL = defaultURL.deletingLastPathComponent()
        let fileName = "db_schema_v\(schemaVersion)"
        let destinationUrl = defaultParentURL.appendingPathComponent(fileName + ".realm")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            try! FileManager.default.removeItem(at: destinationUrl)
        }
        let bundleUrl = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "realm")!
        try! FileManager.default.copyItem(at: bundleUrl, to: destinationUrl)
        return destinationUrl
    }

    func testMigration_v2_Latest_LocalVideo() throws {
        let config = Realm.Configuration(
            fileURL: realmUrl(for: 2),
            schemaVersion: REALM_SCHEMA_VERSION,
            migrationBlock: { [weak self] migration, oldSchemaVersion in
                guard let self else { return }
                subject.migrateForV3(migration: migration, oldSchemaVersion: oldSchemaVersion)
            }
        )
        let realm = try! Realm(configuration: config)

        let expectedData = LocalVideoWallpaper(
            date: Date(timeIntervalSinceReferenceDate: 735346290.959397),
            url: URL(string: "file:///Users/niitsumahiroyasu/Library/Containers/com.nhiro1109.wallpaper-play/Data/Library/Application%20Support/latest-video/latest.mov")!,
            config: .init(size: 0, isMute: true, backgroundColor: nil)
        )

        let result = realm.objects(LocalVideoWallpaper.self).first!

        XCTAssertEqual(result.url, expectedData.url)
        XCTAssertEqual(result.date, expectedData.date)
        XCTAssertEqual(result.config!.size, expectedData.config!.size)
        XCTAssertEqual(result.config!.isMute, expectedData.config!.isMute)
    }

    func testMigration_v2_Latest_YouTube() throws {
        let config = Realm.Configuration(
            fileURL: realmUrl(for: 2),
            schemaVersion: REALM_SCHEMA_VERSION,
            migrationBlock: { [weak self] migration, oldSchemaVersion in
                guard let self else { return }
                subject.migrateForV4(migration: migration, oldSchemaVersion: oldSchemaVersion)
            }
        )
        let realm = try! Realm(configuration: config)

        let expectedData1 = YouTubeWallpaper(
            date: Date(timeIntervalSinceReferenceDate: 717989777.394572),
            videoId: "CtWh0IPXLX8",
            isMute: true
        )
        let expectedData2 = YouTubeWallpaper(
            date: Date(timeIntervalSinceReferenceDate: 735895205.434864),
            videoId: "Wr8egRRLU28",
            isMute: false
        )

        let result1 = realm.objects(YouTubeWallpaper.self)[0]
        let result2 = realm.objects(YouTubeWallpaper.self)[1]

        XCTAssertEqual(result1.date, expectedData1.date)
        XCTAssertEqual(result1.videoId, expectedData1.videoId)
        XCTAssertEqual(result1.isMute, expectedData1.isMute)

        XCTAssertEqual(result2.date, expectedData2.date)
        XCTAssertEqual(result2.videoId, expectedData2.videoId)
        XCTAssertEqual(result2.isMute, expectedData2.isMute)
    }

    func testMigration_v4_Latest_WebPage() throws {
        let config = Realm.Configuration(
            fileURL: realmUrl(for: 4),
            schemaVersion: REALM_SCHEMA_VERSION
        )
        let realm = try! Realm(configuration: config)

        let expectedData = WebPageWallpaper(
            date: Date(timeIntervalSinceReferenceDate: 735973757.98516),
            url: URL(string: "https://github.com/")!,
            arrowOperation: nil
        )

        let result = realm.objects(WebPageWallpaper.self)[0]

        XCTAssertEqual(result.date, expectedData.date)
        XCTAssertEqual(result.url, expectedData.url)
        XCTAssertEqual(result.arrowOperation, expectedData.arrowOperation)
    }

    func testMigration_v4_Latest_LocalVideo() throws {
        let config = Realm.Configuration(
            fileURL: realmUrl(for: 4),
            schemaVersion: REALM_SCHEMA_VERSION
        )
        let realm = try! Realm(configuration: config)

        let expectedData = LocalVideoWallpaper(
            date: Date(timeIntervalSinceReferenceDate: 735289771.339464),
            url: URL(string: "file:///Users/niitsumahiroyasu/Library/Containers/com.debug.nhiro1109.wallpaper-play/Data/Library/Application%20Support/latest-video/latest.mov")!,
            config: .init(size: 0, isMute: true, backgroundColor: nil)
        )

        let result = realm.objects(LocalVideoWallpaper.self).first!

        XCTAssertEqual(result.url, expectedData.url)
        XCTAssertEqual(result.date, expectedData.date)
        XCTAssertEqual(result.config!.size, expectedData.config!.size)
        XCTAssertEqual(result.config!.isMute, expectedData.config!.isMute)
        XCTAssertEqual(result.config!.backgroundColor, expectedData.config!.backgroundColor)
    }
}
