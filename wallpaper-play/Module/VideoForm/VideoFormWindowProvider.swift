import Foundation

protocol VideoFormWindowProvidable {
    var windowController: SettingWindowController { get }
}

final class VideoFormWindowProvider: VideoFormWindowProvidable {
    let windowController: SettingWindowController = SettingWindowController(windowNibName: .windowController.videForm)
}
