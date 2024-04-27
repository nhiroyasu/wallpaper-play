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
        let videoFormWindowController = videoFormWindowProvider.windowController
        if (videoFormWindowController.contentViewController as? VideoFormSplitViewController) == nil {
            let coordinator = VideoFormCoordinator()
            videoFormWindowController.contentViewController = coordinator.create()
        }
        videoFormWindowController.window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        videoFormWindowProvider.windowController.close()
    }
}
