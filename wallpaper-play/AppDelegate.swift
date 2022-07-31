import Cocoa
import Injectable

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var wallMovieWindowController: WallMovieWindowController!
    private var wallMovieViewController: WallMovieViewController!
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var applicationService: ApplicationService!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        buildStatusMenu()

        applicationService = Injector.shared.build()
        applicationService.applicationDidFinishLaunching()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        applicationService.applicationDidBecomeActive()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func buildStatusMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("MenuIcon"))
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Wallpaper", action: #selector(didTapWallPaperItem), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preference", action: #selector(didTapPreferenceItem), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func didTapWallPaperItem() {
        applicationService.didTapWallPaperItem()
    }
    
    @objc func didTapPreferenceItem() {
        applicationService.didTapPreferenceItem()
    }
}

