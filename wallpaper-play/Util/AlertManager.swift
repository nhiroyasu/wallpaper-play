import Foundation
import Cocoa

/// @mockable
protocol AlertManager {
    func info(msg: String, completionHandler: @escaping () -> Void)
    func warning(msg: String, completionHandler: @escaping () -> Void)
}

class AlertManagerImpl: AlertManager {
    
    private func buildAlert(msg: String, type: NSAlert.Style) -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = type
        alert.messageText = msg
        return alert
    }
    
    func info(msg: String, completionHandler: @escaping () -> Void) {
        let alert = buildAlert(msg: msg, type: .informational)
        let response = alert.runModal()
        switch response {
        case .cancel:
            completionHandler()
        default:
            break
        }
    }
    
    func warning(msg: String, completionHandler: @escaping () -> Void) {
        let alert = buildAlert(msg: msg, type: .warning)
        let response = alert.runModal()
        switch response {
        case .cancel:
            completionHandler()
        default:
            break
        }
    }
}
