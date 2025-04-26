import Cocoa

struct VideoPlayRequest {
    let url: URL
    let mute: Bool
    let videoSize: VideoSize
    let backgroundColor: NSColor?
    let target: WallpaperDisplayTarget
}
