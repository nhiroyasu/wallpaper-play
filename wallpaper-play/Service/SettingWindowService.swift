import AppKit
import Injectable

@MainActor
protocol SettingWindowService {
    func show()
    func close()
}

final class SettingWindowServiceImpl: SettingWindowService {
    private var windowController: SettingWindowController?
    private var coordinator: SettingCoordinator!

    func show() {
        if let windowController {
            windowController.window?.center()
            windowController.window?.makeKeyAndOrderFront(nil)
        } else {
            let windowController = SettingWindowController(windowNibName: String(describing: SettingWindowController.self))
            if (windowController.contentViewController as? SettingSplitViewController) == nil {
                coordinator = SettingCoordinator(injector: Injector.shared)
                windowController.contentViewController = coordinator.create()
            }
            windowController.window?.center()
            windowController.window?.makeKeyAndOrderFront(nil)
            self.windowController = windowController
        }
    }

    func close() {
        windowController?.close()
        coordinator = nil
    }
}
