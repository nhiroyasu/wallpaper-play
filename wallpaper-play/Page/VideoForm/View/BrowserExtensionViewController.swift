import Cocoa
import SafariServices

#if DEBUG
fileprivate let safariExtensionBundleID = "com.debug.nhiro1109.wallpaper-play.safari-extension"
#else
fileprivate let safariExtensionBundleID = "com.nhiro1109.wallpaper-play.safari-extension"
#endif

fileprivate let chromeWebStoreUrl = URL(string: "https://chromewebstore.google.com/detail/wallpaperplay-browser-ext/kdhghbkhfpfoppoaamgbgompifppglme")!

class BrowserExtensionViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func didTapSafariPreferenceButton(_ sender: Any) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: safariExtensionBundleID) { error in
            guard error == nil else {
                return
            }

            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    @IBAction func didTapChromeWebStoreButton(_ sender: Any) {
        NSWorkspace.shared.open(chromeWebStoreUrl)
    }
}
