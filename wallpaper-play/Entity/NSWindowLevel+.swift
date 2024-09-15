import AppKit

extension NSWindow.Level {
    static let desktopAbove: NSWindow.Level = .init(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
    static let desktopIconAbove: NSWindow.Level = .init(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
}
