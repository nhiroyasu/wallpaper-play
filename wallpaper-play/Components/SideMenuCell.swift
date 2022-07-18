import Cocoa

class SideMenuCell: NSTableCellView {

    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func set(icon: NSImage?, title: String) {
        iconImageView.image = icon
        titleLabel.stringValue = title
    }
}
