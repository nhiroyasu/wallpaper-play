import AppKit

extension NSColor {
    var hex: ColorHex {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return (Int(r * 0xff) << 16) + (Int(g * 0xff) << 8) + Int(b * 0xff)
    }

    convenience init(hex: ColorHex, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xff0000) >> 16) / CGFloat(0xff)
        let g = CGFloat((hex & 0x00ff00) >> 8) / CGFloat(0xff)
        let b = CGFloat(hex & 0x0000ff) / CGFloat(0xff)
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0.0), 1.0))
    }
}
