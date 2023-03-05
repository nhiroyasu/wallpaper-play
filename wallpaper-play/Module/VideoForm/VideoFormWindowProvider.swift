import Foundation

protocol VideoFormWindowProvidable {
    var windowController: VideoFormWindowController { get }
}

final class VideoFormWindowProvider: VideoFormWindowProvidable {
    let windowController: VideoFormWindowController = VideoFormWindowController(windowNibName: .windowController.videForm)
}
