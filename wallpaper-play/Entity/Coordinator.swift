import AppKit

public protocol WindowCoordinator {
    func createWindow() -> NSWindow
}

@MainActor
public protocol BaseCoordinator {}

public protocol EntryCoordinator: BaseCoordinator {
    func create() -> NSViewController
}

public protocol PresentCoordinator: BaseCoordinator {
    func present(from parentVC: NSViewController)
}
