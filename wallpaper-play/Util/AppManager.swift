import AppKit

protocol AppManager {
    func setVisibilityIcon(_ value: Bool)
    func openBrowser(url: URL)
}

class AppManagerImpl: AppManager {
    func setVisibilityIcon(_ value: Bool) {
        NSApp.setActivationPolicy(value ? .regular : .accessory)
    }

    func openBrowser(url: URL) {
        NSWorkspace.shared.open(url)
    }
}
