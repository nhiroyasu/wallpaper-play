import AppKit

extension CGImage {
    var size: CGSize {
        return CGSize(width: width, height: height)
    }

    var toNSImage: NSImage {
        return NSImage(cgImage: self, size: size)
    }
}
