import Foundation
import Injectable

protocol PlaylistRepository {
    @MainActor func save(_ data: Playlist) async throws
    @MainActor func delete(id: UUID) async throws
    func fetchAll() -> [Playlist]
}

class PlaylistRepositoryImpl: PlaylistRepository {
    private let realmService: any RealmService

    init(injector: any Injectable) {
        realmService = injector.build()
    }

    func save(_ data: Playlist) async throws {
        let realm = realmService.buildRealm()

        let items: [PlaylistItemModel] = data.videos.map { video in
            PlaylistItemModel(url: video.url)
        }
        let model = PlaylistModel(
            date: Date(),
            id: data.id,
            name: data.name,
            playbackMode: data.playbackMode.rawValue,
            videoSize: data.videoSize.rawValue,
            backgroundColor: data.backgroundColor,
            isMute: data.isMute,
            items: items
        )

        do {
            try await realm.asyncWrite {
                realm.add(model)
            }
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }

    func fetchAll() -> [Playlist] {
        let realm = realmService.buildRealm()
        let models = realm.objects(PlaylistModel.self).sorted(byKeyPath: "date", ascending: false)
        let list = models.map { model in
            let videos = model.items.map { item in
                Playlist.Video(url: item.url)
            }
            return Playlist(
                id: model.uuid,
                name: model.name,
                playbackMode: PlaylistPlaybackMode(rawValue: model.playbackMode) ?? .inOrder,
                videoSize: VideoSize(rawValue: model.videoSize) ?? .aspectFill,
                backgroundColor: model.backgroundColor,
                isMute: model.isMute,
                videos: Array(videos)
            )
        }
        return Array(list)
    }

    func delete(id: UUID) async throws {
        let realm = realmService.buildRealm()
        let model = realm.objects(PlaylistModel.self)
            .filter("uuid == %@", id)
            .first
        guard let model else {
            return
        }

        do {
            try await realm.asyncWrite {
                realm.delete(model)
            }
        } catch {
            #if DEBUG
            fatalError(error.localizedDescription)
            #else
            NSLog(error.localizedDescription, [])
            #endif
        }
    }
}
