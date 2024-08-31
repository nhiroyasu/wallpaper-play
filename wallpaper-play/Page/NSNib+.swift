import Foundation
import AppKit

extension NSNib.Name {
    
    static let windowController = WindowController()
    
    struct WindowController {
        let videForm = String(describing: SettingWindowController.self)
    }
}
