import Cocoa
import Injectable

class VideoFormWindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = Bundle.main.infoDictionary!["CFBundleName"] as! String
        displayFront()
    }
    
    func displayFront() {
        window?.level = .floating
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.window?.level = .normal
            self.window?.becomeMain()
            self.window?.becomeKey()
        }
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
    
    func windowWillClose(_ notification: Notification) {
        Injector.shared.buildSafe(NotificationManager.self)?.push(name: .requestVisibilityIcon, param: nil)
    }
}
