import Cocoa
import Injectable

class WallMovieWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.title = "Wallpaper Window"
        window?.styleMask = [.borderless]
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window?.canBecomeVisibleWithoutLogin = true
        window?.hasShadow = false
        window?.canHide = false
        window?.level = .init(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
    
    func showWindow(_ sender: Any?, display: WallpaperKind) {
        showWindow(sender)
        (contentViewController as? WallMovieViewController)?.action.show(display)
    }
    
    func fitFrame(_ frame: NSRect) {
        window?.setFrame(frame, display: true)
    }
}

extension WallMovieWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        (contentViewController as? WallMovieViewController)?.webView.loadHTMLString("", baseURL: nil)
        contentViewController = nil
    }
}
