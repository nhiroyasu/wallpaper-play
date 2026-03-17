import Foundation
import Injectable

protocol PlaylistUseCase {
    func fetchPlaylists() -> [Playlist]
    func deletePlaylist(id: UUID) async throws
    func playPlaylist(id: UUID)
}

class PlaylistUseCaseImpl: PlaylistUseCase {
    private let playlistRepository: any PlaylistRepository
    private let applicationFileManager: any ApplicationFileManager
    private let fileManager: FileManager

    init(injector: any Injectable) {
        self.playlistRepository = injector.build()
        self.applicationFileManager = injector.build()
        self.fileManager = .default
    }

    func fetchPlaylists() -> [Playlist] {
        playlistRepository.fetchAll()
    }

    func deletePlaylist(id: UUID) async throws {
        try await playlistRepository.delete(id: id)
        guard let playlistsRootDirectory = applicationFileManager.getDirectory("playlist") else {
            return
        }
        let playlistDirectory = playlistsRootDirectory.appendingPathComponent(id.uuidString)
        guard fileManager.fileExists(atPath: playlistDirectory.path) else {
            return
        }
        try fileManager.removeItem(at: playlistDirectory)
    }

    func playPlaylist(id _: UUID) {
    }
}
