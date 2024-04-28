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

    func applicationDidBecomeActive(_ notification: Notification) {
        applicationService.didBecomeActive()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        applicationService.applicationOpen(urls: urls)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        applicationService.dockMenu()
    }
    
    private func buildStatusMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("MenuIcon"))
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Wallpaper", action: #selector(didTapWallPaperItem), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preference", action: #selector(didTapPreferenceItem), keyEquivalent: ","))
        menu.addItem(.separator())
        #if DEBUG
        menu.addItem(NSMenuItem(title: "Debug", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open .realm", action: #selector(didTapOpenRealm), keyEquivalent: ""))
        menu.addItem(.separator())
        #endif
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func didTapWallPaperItem() {
        applicationService.didTapWallPaperItem()
    }
    
    @objc func didTapPreferenceItem() {
        applicationService.didTapPreferenceItem()
    }

    @objc func didTapOpenRealm() {
        applicationService.didTapOpenRealm()
    }
}

