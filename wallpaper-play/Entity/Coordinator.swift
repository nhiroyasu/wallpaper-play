import AppKit

public protocol WindowCoordinator {
    func createWindow() -> NSWindow
}

public protocol Coordinator {
    func create() -> NSViewController
}

public protocol NavigationCoordinator: Coordinator {
    func start()
    func dismiss()
}
