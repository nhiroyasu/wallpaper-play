import AppKit

public protocol Coordinator {
    func create() -> NSViewController
}

public protocol NavigationCoordinator: Coordinator {
    func start()
    func dismiss()
}
