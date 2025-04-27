import Cocoa

extension NSScreen {
    var deviceIdentifier: UInt32 {
        (self.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! NSNumber).uint32Value
    }
}
