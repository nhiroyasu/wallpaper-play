import AppKit
import Injectable

protocol SettingWindowService {
    func show()
    func close()
}

final class SettingWindowServiceImpl: SettingWindowService {
    private var windowController: SettingWindowController?

    func show() {
        let windowController = SettingWindowController(windowNibName: String(describing: SettingWindowController.self))
        if (windowController.contentViewController as? SettingSplitViewController) == nil {
            let coordinator = SettingCoordinator(injector: Injector.shared)
            windowController.contentViewController = coordinator.create()
        }
        windowController.window?.center()
        windowController.window?.makeKeyAndOrderFront(nil)
        self.windowController = windowController
    }

    func close() {
        windowController?.close()
    }
}
