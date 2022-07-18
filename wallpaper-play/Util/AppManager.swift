import AppKit

protocol AppManager {
    func setVisibilityIcon(_ value: Bool)
}

class AppManagerImpl: AppManager {
    func setVisibilityIcon(_ value: Bool) {
        NSApp.setActivationPolicy(value ? .regular : .accessory)
    }
}
