import Cocoa
import Injectable

enum SideMenuItem: String, CaseIterable {
    case localVideo = "Video"
    case youtube = "YouTube"
    case webpage = "Web"
    case browserExtension = "Browser Extension"
    case preference = "Preference"
    case about = "About"

    var icon: NSImage? {
        switch self {
        case .localVideo:
            return NSImage(systemSymbolName: "film.fill", accessibilityDescription: nil)
        case .youtube:
            return NSImage(systemSymbolName: "play.rectangle.fill", accessibilityDescription: nil)
        case .webpage:
            return NSImage(systemSymbolName: "safari.fill", accessibilityDescription: nil)
        case .browserExtension:
            return NSImage(systemSymbolName: "puzzlepiece.extension.fill", accessibilityDescription: nil)
        case .preference:
            return NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)
        case .about:
            return NSImage(systemSymbolName: "person.fill", accessibilityDescription: nil)
        }
    }
}

class SideMenuViewController: NSViewController {
    lazy var notificationManager: NotificationManager = Injector.shared.build()

    @IBOutlet weak var outlineView: NSOutlineView! {
        didSet {
            outlineView.dataSource = self
            outlineView.delegate = self
            outlineView.selectionHighlightStyle = .regular
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationManager.observe(name: .selectedSideMenu) { [weak self] param in
            guard let self = self, let param = param as? SideMenuItem else { return }
            self.selectItem(param)
        }
    }
    
    func selectItem(_ item: SideMenuItem) {
        if let index = SideMenuItem.allCases.firstIndex(where: { $0 == item }) {
            outlineView.selectRowIndexes(.init(integer: index), byExtendingSelection: false)
        }
    }
}

extension SideMenuViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return SideMenuItem.allCases.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return SideMenuItem.allCases[index].rawValue
        } else {
            return ""
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        48.0
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, tintConfigurationForItem item: Any) -> NSTintConfiguration? {
        .monochrome
    }
}

extension SideMenuViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let itemValue = item as? String, let itemType = SideMenuItem(rawValue: itemValue) else {
            return nil
        }
        let cell = outlineView.makeView(withIdentifier: .init("sideMenuCell"), owner: self) as? SideMenuCell
        cell?.set(icon: itemType.icon, title: itemType.rawValue)
        return cell
    }
    
    func outlineViewSelectionIsChanging(_ notification: Notification) {
        let item = SideMenuItem.allCases[outlineView.selectedRow]
        Injector.shared.build(NotificationManager.self).push(name: .selectedSideMenu, param: item)
    }
}
