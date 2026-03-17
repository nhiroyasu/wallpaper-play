import Foundation
import Injectable

protocol PlaylistFormUseCase {
    func savePlaylist(
        name: String,
        playbackMode: PlaylistPlaybackMode,
        videoSize: VideoSize,
        backgroundColor: ColorHex,
        isMute: Bool,
        videoUrls: [URL]
    ) async throws
}

class PlaylistFormUseCaseImpl: PlaylistFormUseCase {
    private let notificationManager: any NotificationManager
    private let playlistRepository: any PlaylistRepository
    private let applicationFileManager: any ApplicationFileManager
    private let fileManager: FileManager

    init(injector: any Injectable) {
        self.notificationManager = injector.build()
        self.playlistRepository = injector.build()
        self.applicationFileManager = injector.build()
        self.fileManager = .default
    }

    func savePlaylist(
        name: String,
        playbackMode: PlaylistPlaybackMode,
        videoSize: VideoSize,
        backgroundColor: ColorHex,
        isMute: Bool,
        videoUrls: [URL]
    ) async throws {
        let id = UUID()
        let fileManager = FileManager.default
        guard let playlistsRootDirectory = applicationFileManager.getDirectory("playlist") else {
            throw NSError(domain: "PlaylistFormUseCase", code: 1)
        }
        let playlistDirectory = playlistsRootDirectory.appendingPathComponent(id.uuidString)
        if fileManager.fileExists(atPath: playlistDirectory.path) == false {
            try fileManager.createDirectory(at: playlistDirectory, withIntermediateDirectories: false)
        }
        guard fileManager.fileExists(atPath: playlistDirectory.path) else {
            throw NSError(domain: "PlaylistFormUseCase", code: 1)
        }
        let savedVideoUrls: [URL] = try videoUrls.map { url in
            let originalFileName = url.lastPathComponent.isEmpty ? "video" : url.lastPathComponent
            let baseName = (originalFileName as NSString).deletingPathExtension
            let pathExtension = (originalFileName as NSString).pathExtension
            var candidateName = originalFileName
            var counter = 1
            var storedFileUrl = playlistDirectory.appendingPathComponent(candidateName)
            while fileManager.fileExists(atPath: storedFileUrl.path) {
                candidateName = pathExtension.isEmpty
                    ? "\(baseName)_\(counter)"
                    : "\(baseName)_\(counter).\(pathExtension)"
                storedFileUrl = playlistDirectory.appendingPathComponent(candidateName)
                counter += 1
            }
            try fileManager.copyItem(at: url, to: storedFileUrl)
            return storedFileUrl
        }

        let playlist = Playlist(
            id: id,
            name: name,
            playbackMode: playbackMode,
            videoSize: videoSize,
            backgroundColor: backgroundColor,
            isMute: isMute,
            videos: savedVideoUrls.map { Playlist.Video(url: $0) }
        )

        try await playlistRepository.save(playlist)

        notificationManager.push(
            name: .requestPlaylist,
            param: id
        )
    }
}
