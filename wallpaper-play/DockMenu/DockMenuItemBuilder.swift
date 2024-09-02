import AppKit
import Injectable

protocol DockMenuItemBuilder {
    func preferenceMenu() -> NSMenuItem
}

final class DockMenuItemBuilderImpl: DockMenuItemBuilder {
    private let action: any DockMenuAction

    init(injector: any Injectable) {
        self.action = injector.build()
    }

    func preferenceMenu() -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: "Preference",
            action: #selector(self.preferenceAction),
            keyEquivalent: ""
        )
        menuItem.target = self
        return menuItem
    }

    @objc func preferenceAction() {
        action.preferenceAction()
    }
}
