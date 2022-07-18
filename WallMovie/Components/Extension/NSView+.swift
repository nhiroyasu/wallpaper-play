import AppKit

extension NSView {
    func fitAllAnchor(_ target: NSView) {
        self.subviews.insert(target, at: 0)
        target.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        target.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        target.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        target.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
}
