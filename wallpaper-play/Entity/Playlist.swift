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
