import Cocoa
import Injectable

class WallpaperWindow: NSWindow {
    init(contentViewController: NSViewController, windowLevel: NSWindow.Level) {
        super.init(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        self.contentViewController = contentViewController
        title = "Wallpaper Window"
        styleMask = [.borderless]
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        canBecomeVisibleWithoutLogin = true
        hasShadow = false
        canHide = false
        level = windowLevel
        isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool {
        true
    }
}
