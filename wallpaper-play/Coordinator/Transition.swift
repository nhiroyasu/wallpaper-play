import AppKit

public protocol Transitionable {
    func present(
        _ viewController: NSViewController,
        animator: NSViewControllerPresentationAnimator
    )
    func dismiss(_ viewController: NSViewController)
    func present(
        _ viewController: NSViewController,
        asPopoverRelativeTo positioningRect: NSRect,
        of positioningView: NSView,
        preferredEdge: NSRectEdge,
        behavior: NSPopover.Behavior
    )
    func presentAsModalWindow(_ viewController: NSViewController)
    func presentAsSheet(_ viewController: NSViewController)
}

extension NSViewController: Transitionable {}
