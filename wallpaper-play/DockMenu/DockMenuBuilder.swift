import AppKit
import Injectable

protocol DockMenuBuilder {
    func build() -> NSMenu
}

final class DockMenuBuilderImpl: DockMenuBuilder {
    private let dockMenuItemBuilder: DockMenuItemBuilder

    init(injector: Injectable) {
        dockMenuItemBuilder = injector.build()
    }

    func build() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(dockMenuItemBuilder.preferenceMenu())
        return menu
    }
}
