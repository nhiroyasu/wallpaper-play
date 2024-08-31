import AppKit
import Injectable

protocol VideoFormWindowPresenter {
    func show()
    func close()
}

final class VideoFormWindowPresenterImpl: VideoFormWindowPresenter {
    private let videoFormWindowProvider: VideoFormWindowProvidable

    init(injector: Injectable) {
        self.videoFormWindowProvider = injector.build()
    }

    func show() {
        let SettingWindowController = videoFormWindowProvider.windowController
        if (SettingWindowController.contentViewController as? SettingSplitViewController) == nil {
            let coordinator = VideoFormCoordinator()
            SettingWindowController.contentViewController = coordinator.create()
        }
        SettingWindowController.window?.center()
        SettingWindowController.window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        videoFormWindowProvider.windowController.close()
    }
}
