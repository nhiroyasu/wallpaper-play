import AppKit

extension NSView {
    func fitAllAnchor(_ target: NSView) {
        self.subviews.insert(target, at: 0)
        target.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        target.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        target.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        target.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    func fitAllAnchor(_ target: NSView, top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.subviews.insert(target, at: 0)
        target.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        target.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        target.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left).isActive = true
        target.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right).isActive = true
    }
}
