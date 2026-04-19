import XCTest
import RealmSwift
import Swinject
import Injectable
@testable import Wallpaper_Play

class WallpaperHistoryServiceTests: XCTestCase {
    private var subject: WallpaperHistoryServiceImpl!
    private var realmService: InMemoryRealmService!

    override func setUpWithError() throws {
        let container = Container()
        let realmService = InMemoryRealmService(identifier: UUID().uuidString)
        container.register((any RealmService).self) { _ in realmService }
            .inObjectScope(.container)
        container.register((any PlaylistRepository).self) { injector in
            PlaylistRepositoryImpl(injector: injector)
        }
        let injector = Injector(container: container)
        self.realmService = realmService
        self.subject = WallpaperHistoryServiceImpl(injector: injector)
    }

    func testStorePlaylist() {
        let playlistId = UUID()
        let date = Date(timeIntervalSince1970: 1000)

        subject.store(
            PlaylistWallpaper(
                date: date,
                playlistId: playlistId,
                targetMonitor: nil
            )
        )

        let result = subject.fetchPlaylist()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].date, date)
        XCTAssertEqual(result[0].playlistId, playlistId)
        XCTAssertNil(result[0].targetMonitor)
    }

    func testFetchLatestWallpaperReturnsPlaylistWhenResolvable() {
        let playlistId = UUID()
        insertPlaylistModel(id: playlistId)
        subject.store(
            YouTubeWallpaper(
                date: Date(timeIntervalSince1970: 1000),
                videoId: "youtube-id",
                isMute: true,
                size: VideoSize.aspectFill.rawValue,
                targetMonitor: nil
            )
        )
        subject.store(
            PlaylistWallpaper(
                date: Date(timeIntervalSince1970: 2000),
                playlistId: playlistId,
                targetMonitor: nil
            )
        )

        let result = subject.fetchLatestWallpaper(monitorFilter: .all)
        guard let result else {
            XCTFail("latest wallpaper should exist")
            return
        }
        switch result.kind {
        case .playlist(let playlist):
            XCTAssertEqual(playlist.id, playlistId)
        default:
            XCTFail("latest wallpaper should be playlist")
        }
        XCTAssertTrue(result.isAll)
    }

    func testFetchLatestWallpaperReturnsNilWhenPlaylistCannotBeResolved() {
        subject.store(
            YouTubeWallpaper(
                date: Date(timeIntervalSince1970: 1000),
                videoId: "youtube-id",
                isMute: true,
                size: VideoSize.aspectFill.rawValue,
                targetMonitor: nil
            )
        )
        subject.store(
            PlaylistWallpaper(
                date: Date(timeIntervalSince1970: 2000),
                playlistId: UUID(),
                targetMonitor: nil
            )
        )

        let result = subject.fetchLatestWallpaper(monitorFilter: .all)
        XCTAssertNil(result)
    }

    func testFetchLatestWallpaperReturnsVideoWhenVideoIsLatest() {
        insertOldPlaylistHistory()
        let url = URL(fileURLWithPath: "/tmp/video.mov")
        subject.store(
            LocalVideoWallpaper(
                date: Date(timeIntervalSince1970: 3000),
                url: url,
                config: .init(
                    size: VideoSize.aspectFill.rawValue,
                    isMute: true,
                    backgroundColor: nil
                ),
                targetMonitor: nil
            )
        )

        let result = subject.fetchLatestWallpaper(monitorFilter: .all)
        guard let result else {
            XCTFail("latest wallpaper should exist")
            return
        }
        switch result.kind {
        case .video(let resultUrl, _, _, _):
            XCTAssertEqual(resultUrl, url)
        default:
            XCTFail("latest wallpaper should be video")
        }
    }

    func testFetchLatestWallpaperReturnsYoutubeWhenYoutubeIsLatest() {
        insertOldPlaylistHistory()
        subject.store(
            YouTubeWallpaper(
                date: Date(timeIntervalSince1970: 3000),
                videoId: "youtube-id",
                isMute: true,
                size: VideoSize.aspectFill.rawValue,
                targetMonitor: nil
            )
        )

        let result = subject.fetchLatestWallpaper(monitorFilter: .all)
        guard let result else {
            XCTFail("latest wallpaper should exist")
            return
        }
        switch result.kind {
        case .youtube(let videoId, _, _):
            XCTAssertEqual(videoId, "youtube-id")
        default:
            XCTFail("latest wallpaper should be youtube")
        }
    }

    func testFetchLatestWallpaperReturnsWebWhenWebIsLatest() {
        insertOldPlaylistHistory()
        let url = URL(string: "https://example.com")!
        subject.store(
            WebPageWallpaper(
                date: Date(timeIntervalSince1970: 3000),
                url: url,
                arrowOperation: true,
                targetMonitor: nil
            )
        )

        let result = subject.fetchLatestWallpaper(monitorFilter: .all)
        guard let result else {
            XCTFail("latest wallpaper should exist")
            return
        }
        switch result.kind {
        case .web(let resultUrl, let arrowOperation):
            XCTAssertEqual(resultUrl, url)
            XCTAssertTrue(arrowOperation)
        default:
            XCTFail("latest wallpaper should be web")
        }
    }

    func testFetchLatestWallpaperReturnsCameraWhenCameraIsLatest() {
        insertOldPlaylistHistory()
        subject.store(
            CameraWallpaper(
                date: Date(timeIntervalSince1970: 3000),
                deviceId: "camera-id",
                size: VideoSize.aspectFill.rawValue,
                targetMonitor: nil
            )
        )

        let result = subject.fetchLatestWallpaper(monitorFilter: .all)
        guard let result else {
            XCTFail("latest wallpaper should exist")
            return
        }
        switch result.kind {
        case .camera(let deviceId, _):
            XCTAssertEqual(deviceId, "camera-id")
        default:
            XCTFail("latest wallpaper should be camera")
        }
    }

    private func insertOldPlaylistHistory() {
        let playlistId = UUID()
        insertPlaylistModel(id: playlistId)
        subject.store(
            PlaylistWallpaper(
                date: Date(timeIntervalSince1970: 1000),
                playlistId: playlistId,
                targetMonitor: nil
            )
        )
    }

    private func insertPlaylistModel(id: UUID) {
        let realm = realmService.buildRealm()
        let model = PlaylistModel(
            date: Date(timeIntervalSince1970: 500),
            id: id,
            name: "playlist",
            playbackMode: PlaylistPlaybackMode.inOrder.rawValue,
            videoSize: VideoSize.aspectFill.rawValue,
            backgroundColor: 0xFFFFFF,
            isMute: true,
            items: [PlaylistItemModel(url: URL(fileURLWithPath: "/tmp/playlist.mov"))]
        )
        try! realm.write {
            realm.add(model)
        }
    }
}

private class InMemoryRealmService: RealmService {
    private let config: Realm.Configuration

    init(identifier: String) {
        self.config = Realm.Configuration(
            inMemoryIdentifier: identifier,
            schemaVersion: REALM_SCHEMA_VERSION
        )
    }

    func buildRealm() -> Realm {
        try! Realm(configuration: config)
    }

    func compactRealm() {}

    func getRealmURL() -> URL? {
        config.fileURL
    }
}
