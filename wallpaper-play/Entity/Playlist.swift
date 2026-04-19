import Foundation

struct Playlist {
    let id: UUID
    let name: String
    let playbackMode: PlaylistPlaybackMode
    let videoSize: VideoSize
    let backgroundColor: ColorHex
    let isMute: Bool
    let videos: [Video]

    struct Video {
        let url: URL
    }
}

extension Playlist {
    func resolvedForPlayback(
        shuffle: ([Video]) -> [Video] = { $0.shuffled() }
    ) -> Playlist {
        let playbackVideos: [Video] = switch playbackMode {
        case .inOrder:
            videos
        case .shuffle:
            shuffle(videos)
        }
        return Playlist(
            id: id,
            name: name,
            playbackMode: playbackMode,
            videoSize: videoSize,
            backgroundColor: backgroundColor,
            isMute: isMute,
            videos: playbackVideos
        )
    }
}
