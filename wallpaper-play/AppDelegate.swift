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
        
        // TLDR: save current wallpapers
        let oldWallpapersBackup = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appending(path: "wallpapers_backup.json"))
        let oldWallpapers = [Int : URL]()
        NSScreen.screens.forEach { screen in
            DispatchQueue.main.async {
                oldWallpapers.updateValue(NSScreen.desktopImageURL(for: screen), forKey: screen.hash)
            }
        }
        guard let _ = try JSONEncoder().encode(oldWallpapers).write(to: oldWallpapersBackup) else {
            print("Failed to back up wallpapers!")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        // Sorry for building pyramids
        // TLDR: set up previous wallpapers
        let oldWallpapersBackup = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appending(path: "wallpapers_backup.json"))
        if(FileManager.default.fileExists(atPath: oldWallpapersBackup.path,
           let oldWallpapers = JSONDecoder().decode([Int : URL].self, from: Data(contentsOf: oldWallpapersBackup)) {
            NSScreen.screens.forEach { screen in
                if let wallpaper = oldWallpapers[screen.hashValue] {
                    DispatchQueue.main.async {
                        screen.setDesktopImageURL(wallpaper, for: screen)
                    }
                }
            }
        } else {
            print("Failed to restore wallpapers!")
        }
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

