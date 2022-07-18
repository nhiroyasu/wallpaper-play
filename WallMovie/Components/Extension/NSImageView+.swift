import AppKit

extension NSImageView {
    func setImage(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            image = NSImage(data: data)
        } catch {
#if DEBUG
            fatalError(error.localizedDescription)
#else
            NSLog(error.localizedDescription, [])
#endif
        }
    }
}
