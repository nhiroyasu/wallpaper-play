import Cocoa
import Injectable

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var applicationService: any ApplicationService = Injector.shared.build()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initStatusMenu()
        applicationService.applicationDidFinishLaunching()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        applicationService.applicationOpen(urls: urls)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        applicationService.applicationShouldHandleReopen(hasVisibleWindows: flag)
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

    func applicationDidBecomeActive(_ notification: Notification) {
        applicationService.didBecomeActive()
    }

    private func initStatusMenu() {
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

