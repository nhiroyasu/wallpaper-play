import Foundation
import Injectable

protocol PlaylistFormUseCase {
    func createPlaylist(
        name: String,
        playbackMode: PlaylistPlaybackMode,
        videoSize: VideoSize,
        backgroundColor: ColorHex,
        isMute: Bool,
        target: WallpaperDisplayTarget,
        videoUrls: [URL],
        shouldApplyAfterSaving: Bool
    ) async throws
    func updatePlaylist(
        id: UUID,
        name: String,
        playbackMode: PlaylistPlaybackMode,
        videoSize: VideoSize,
        backgroundColor: ColorHex,
        isMute: Bool,
        target: WallpaperDisplayTarget,
        videoUrls: [URL],
        shouldApplyAfterSaving: Bool
    ) async throws
}

class PlaylistFormUseCaseImpl: PlaylistFormUseCase {
    private let wallpaperRequestService: any WallpaperRequestService
    private let playlistRepository: any PlaylistRepository
    private let applicationFileManager: any ApplicationFileManager
    private let fileManager: FileManager

    init(injector: any Injectable) {
        self.wallpaperRequestService = injector.build()
        self.playlistRepository = injector.build()
        self.applicationFileManager = injector.build()
        self.fileManager = .default
    }

    func createPlaylist(
        name: String,
        playbackMode: PlaylistPlaybackMode,
        videoSize: VideoSize,
        backgroundColor: ColorHex,
        isMute: Bool,
        target: WallpaperDisplayTarget,
        videoUrls: [URL],
        shouldApplyAfterSaving: Bool
    ) async throws {
        let id = UUID()
        let playlistDirectory = try getOrCreatePlaylistDirectory(id: id)
        let savedVideoUrls = try copyVideoFiles(videoUrls, to: playlistDirectory)

        let playlist = Playlist(
            id: id,
            name: name,
            playbackMode: playbackMode,
            videoSize: videoSize,
            backgroundColor: backgroundColor,
            isMute: isMute,
            target: target,
            videos: savedVideoUrls.map { Playlist.Video(url: $0) }
        )

        try await playlistRepository.save(playlist)
        if shouldApplyAfterSaving {
            wallpaperRequestService.requestPlaylistWallpaper(
                playlist: PlaylistPlayRequest(playlist: playlist)
            )
        }
    }

    func updatePlaylist(
        id: UUID,
        name: String,
        playbackMode: PlaylistPlaybackMode,
        videoSize: VideoSize,
        backgroundColor: ColorHex,
        isMute: Bool,
        target: WallpaperDisplayTarget,
        videoUrls: [URL],
        shouldApplyAfterSaving: Bool
    ) async throws {
        let playlistDirectory = try getOrCreatePlaylistDirectory(id: id)
        let savedVideoUrls = try resolveEditedVideoFiles(videoUrls, playlistDirectory: playlistDirectory)

        let playlist = Playlist(
            id: id,
            name: name,
            playbackMode: playbackMode,
            videoSize: videoSize,
            backgroundColor: backgroundColor,
            isMute: isMute,
            target: target,
            videos: savedVideoUrls.map { Playlist.Video(url: $0) }
        )

        try await playlistRepository.replace(playlist)
        if shouldApplyAfterSaving {
            wallpaperRequestService.requestPlaylistWallpaper(
                playlist: PlaylistPlayRequest(playlist: playlist)
            )
        }
    }

    private func getOrCreatePlaylistDirectory(id: UUID) throws -> URL {
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
        return playlistDirectory
    }

    private func resolveEditedVideoFiles(
        _ videoUrls: [URL],
        playlistDirectory: URL
    ) throws -> [URL] {
        var resolvedVideoUrls: [URL] = []

        for url in videoUrls {
            let standardizedUrl = url.standardizedFileURL
            let isPlaylistFile = standardizedUrl.deletingLastPathComponent().standardizedFileURL.path == playlistDirectory.standardizedFileURL.path
            if isPlaylistFile && fileManager.fileExists(atPath: standardizedUrl.path) {
                resolvedVideoUrls.append(standardizedUrl)
            } else {
                let copiedFileUrl = try copyVideoFile(url, to: playlistDirectory)
                resolvedVideoUrls.append(copiedFileUrl)
            }
        }

        try removeUnusedFiles(in: playlistDirectory, keep: resolvedVideoUrls)
        return resolvedVideoUrls
    }

    private func copyVideoFiles(
        _ videoUrls: [URL],
        to playlistDirectory: URL
    ) throws -> [URL] {
        try videoUrls.map { url in
            try copyVideoFile(url, to: playlistDirectory)
        }
    }

    private func copyVideoFile(_ url: URL, to playlistDirectory: URL) throws -> URL {
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

    private func removeUnusedFiles(in playlistDirectory: URL, keep urls: [URL]) throws {
        let keptPaths = Set(urls.map { $0.standardizedFileURL.path })
        let files = try fileManager.contentsOfDirectory(
            at: playlistDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        for fileUrl in files {
            let isRegularFile = try fileUrl.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile ?? false
            if isRegularFile == false {
                continue
            }
            if keptPaths.contains(fileUrl.standardizedFileURL.path) {
                continue
            }
            try fileManager.removeItem(at: fileUrl)
        }
    }
}
